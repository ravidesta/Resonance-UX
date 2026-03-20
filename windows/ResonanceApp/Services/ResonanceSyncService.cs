// =============================================================================
// Resonance UX - Sync Service Layer
// Cross-device sync, calm notifications, background biometric monitoring,
// encrypted local SQLite storage, and SignalR real-time connection.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.UI.Dispatching;
using ResonanceApp.Models;
using Windows.ApplicationModel.Background;
using Windows.Storage;
using Windows.UI.Notifications;

namespace ResonanceApp.Services
{
    // =========================================================================
    // Configuration
    // =========================================================================

    /// <summary>
    /// Resonance sync configuration.
    /// </summary>
    public class ResonanceSyncConfig
    {
        public string ApiBaseUrl { get; set; } = "https://api.resonance.app/v1";
        public string SignalRHubUrl { get; set; } = "https://api.resonance.app/hubs/sync";
        public string DatabasePath { get; set; }
        public string EncryptionKeyId { get; set; }
        public TimeSpan SyncInterval { get; set; } = TimeSpan.FromMinutes(5);
        public TimeSpan BiometricPollInterval { get; set; } = TimeSpan.FromMinutes(15);
        public bool EnableBackgroundSync { get; set; } = true;
        public bool EnableCalmNotifications { get; set; } = true;

        public ResonanceSyncConfig()
        {
            var localFolder = ApplicationData.Current.LocalFolder.Path;
            DatabasePath = Path.Combine(localFolder, "resonance.db");
        }
    }

    // =========================================================================
    // Sync Service
    // =========================================================================

    /// <summary>
    /// ResonanceSyncService orchestrates data synchronization across devices.
    ///
    /// Design principles:
    /// - Sync should be invisible. The user never waits for data.
    /// - Conflicts are resolved gently, with the latest edit winning by default.
    /// - Notifications are calm — no red badges, no urgent pings.
    /// - Data is encrypted at rest. Health data gets additional protection.
    /// </summary>
    public class ResonanceSyncService : IDisposable
    {
        // =====================================================================
        // Fields
        // =====================================================================

        private readonly ResonanceSyncConfig _config;
        private readonly HttpClient _httpClient;
        private readonly LocalStorageService _localStorage;
        private readonly CalmNotificationService _notifications;
        private readonly BiometricMonitorService _biometricMonitor;
        private SignalRConnectionManager _signalRManager;
        private CancellationTokenSource _syncCts;
        private Timer _syncTimer;
        private bool _isDisposed;
        private bool _isSyncing;
        private DateTime _lastSyncTime;

        public event EventHandler<SyncCompletedEventArgs> SyncCompleted;
        public event EventHandler<SyncErrorEventArgs> SyncError;
        public event EventHandler<DataChangedEventArgs> RemoteDataChanged;

        public bool IsConnected => _signalRManager?.IsConnected ?? false;
        public DateTime LastSyncTime => _lastSyncTime;

        // =====================================================================
        // Constructor & Initialization
        // =====================================================================

        public ResonanceSyncService(ResonanceSyncConfig config = null)
        {
            _config = config ?? new ResonanceSyncConfig();

            _httpClient = new HttpClient
            {
                BaseAddress = new Uri(_config.ApiBaseUrl),
                Timeout = TimeSpan.FromSeconds(30)
            };
            _httpClient.DefaultRequestHeaders.Add("X-Resonance-Client", "windows-native/1.0");

            _localStorage = new LocalStorageService(_config.DatabasePath, _config.EncryptionKeyId);
            _notifications = new CalmNotificationService();
            _biometricMonitor = new BiometricMonitorService(_config.BiometricPollInterval);
        }

        /// <summary>
        /// Initialize all services: local storage, SignalR, background tasks.
        /// </summary>
        public async Task InitializeAsync()
        {
            // Initialize encrypted local storage
            await _localStorage.InitializeAsync();

            // Set up SignalR real-time connection
            _signalRManager = new SignalRConnectionManager(_config.SignalRHubUrl);
            _signalRManager.DataChanged += OnRemoteDataChanged;
            _signalRManager.ConnectionStatusChanged += OnConnectionStatusChanged;
            await _signalRManager.ConnectAsync();

            // Start periodic sync
            _syncCts = new CancellationTokenSource();
            _syncTimer = new Timer(
                async _ => await PerformSyncAsync(),
                null,
                TimeSpan.Zero,
                _config.SyncInterval);

            // Register background task
            if (_config.EnableBackgroundSync)
            {
                await RegisterBackgroundTaskAsync();
            }

            // Start biometric monitoring
            _biometricMonitor.Start();

            Debug.WriteLine("[Resonance] Sync service initialized.");
        }

        // =====================================================================
        // Sync Operations
        // =====================================================================

        /// <summary>
        /// Perform a full sync cycle:
        /// 1. Push local changes to the API
        /// 2. Pull remote changes
        /// 3. Resolve any conflicts
        /// 4. Update local store
        /// </summary>
        public async Task PerformSyncAsync()
        {
            if (_isSyncing) return;
            _isSyncing = true;

            try
            {
                Debug.WriteLine("[Resonance] Starting sync...");

                // 1. Get local changes since last sync
                var localChanges = await _localStorage.GetChangesSinceAsync(_lastSyncTime);

                // 2. Push local changes
                if (localChanges.Any())
                {
                    var pushResult = await PushChangesAsync(localChanges);
                    if (!pushResult.Success)
                    {
                        Debug.WriteLine($"[Resonance] Push failed: {pushResult.Error}");
                    }
                }

                // 3. Pull remote changes
                var remoteChanges = await PullChangesAsync(_lastSyncTime);

                // 4. Resolve conflicts (last-write-wins with user override option)
                var resolved = ResolveConflicts(localChanges, remoteChanges);

                // 5. Apply changes to local store
                await _localStorage.ApplyChangesAsync(resolved);

                _lastSyncTime = DateTime.UtcNow;

                SyncCompleted?.Invoke(this, new SyncCompletedEventArgs
                {
                    PushedCount = localChanges.Count,
                    PulledCount = remoteChanges.Count,
                    ConflictsResolved = resolved.Count(c => c.WasConflict),
                    SyncTime = _lastSyncTime
                });

                Debug.WriteLine($"[Resonance] Sync complete. Pushed: {localChanges.Count}, Pulled: {remoteChanges.Count}");
            }
            catch (HttpRequestException ex)
            {
                Debug.WriteLine($"[Resonance] Sync network error: {ex.Message}");
                SyncError?.Invoke(this, new SyncErrorEventArgs { Error = ex, IsRecoverable = true });
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Resonance] Sync error: {ex.Message}");
                SyncError?.Invoke(this, new SyncErrorEventArgs { Error = ex, IsRecoverable = false });
            }
            finally
            {
                _isSyncing = false;
            }
        }

        private async Task<SyncPushResult> PushChangesAsync(List<SyncChange> changes)
        {
            try
            {
                var payload = new SyncPushPayload
                {
                    DeviceId = GetDeviceId(),
                    Changes = changes,
                    Timestamp = DateTime.UtcNow
                };

                var response = await _httpClient.PostAsJsonAsync("sync/push", payload, _syncCts.Token);
                response.EnsureSuccessStatusCode();

                return await response.Content.ReadFromJsonAsync<SyncPushResult>();
            }
            catch (Exception ex)
            {
                return new SyncPushResult { Success = false, Error = ex.Message };
            }
        }

        private async Task<List<SyncChange>> PullChangesAsync(DateTime since)
        {
            try
            {
                var url = $"sync/pull?since={since:O}&device={GetDeviceId()}";
                var response = await _httpClient.GetAsync(url, _syncCts.Token);
                response.EnsureSuccessStatusCode();

                var result = await response.Content.ReadFromJsonAsync<SyncPullResult>();
                return result?.Changes ?? new List<SyncChange>();
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Resonance] Pull error: {ex.Message}");
                return new List<SyncChange>();
            }
        }

        private List<SyncChange> ResolveConflicts(List<SyncChange> local, List<SyncChange> remote)
        {
            var resolved = new List<SyncChange>();
            var remoteMap = remote.ToDictionary(c => c.EntityId);

            foreach (var localChange in local)
            {
                if (remoteMap.TryGetValue(localChange.EntityId, out var remoteChange))
                {
                    // Conflict: same entity changed on both sides
                    // Resolution: latest timestamp wins (can be overridden by user)
                    var winner = localChange.Timestamp > remoteChange.Timestamp
                        ? localChange
                        : remoteChange;
                    winner.WasConflict = true;
                    resolved.Add(winner);
                    remoteMap.Remove(localChange.EntityId);
                }
            }

            // Add remaining remote changes (no conflict)
            resolved.AddRange(remoteMap.Values);

            return resolved;
        }

        // =====================================================================
        // Real-Time (SignalR)
        // =====================================================================

        private void OnRemoteDataChanged(object sender, DataChangedEventArgs e)
        {
            Debug.WriteLine($"[Resonance] Real-time update: {e.EntityType} {e.EntityId}");

            // Apply immediately to local store
            Task.Run(async () =>
            {
                await _localStorage.ApplyChangesAsync(new List<SyncChange>
                {
                    new SyncChange
                    {
                        EntityId = e.EntityId,
                        EntityType = e.EntityType,
                        Data = e.Data,
                        Timestamp = DateTime.UtcNow
                    }
                });
            });

            RemoteDataChanged?.Invoke(this, e);
        }

        private void OnConnectionStatusChanged(object sender, bool isConnected)
        {
            Debug.WriteLine($"[Resonance] SignalR connection: {(isConnected ? "connected" : "disconnected")}");
        }

        // =====================================================================
        // Background Task Registration
        // =====================================================================

        private async Task RegisterBackgroundTaskAsync()
        {
            const string taskName = "ResonanceSyncBackgroundTask";

            // Check if already registered
            foreach (var task in BackgroundTaskRegistration.AllTasks)
            {
                if (task.Value.Name == taskName)
                {
                    Debug.WriteLine("[Resonance] Background sync task already registered.");
                    return;
                }
            }

            var access = await BackgroundExecutionManager.RequestAccessAsync();
            if (access == BackgroundAccessStatus.DeniedByUser ||
                access == BackgroundAccessStatus.DeniedBySystemPolicy)
            {
                Debug.WriteLine("[Resonance] Background access denied.");
                return;
            }

            var builder = new BackgroundTaskBuilder
            {
                Name = taskName,
                TaskEntryPoint = "ResonanceApp.Background.SyncBackgroundTask"
            };

            // Trigger every 15 minutes when on WiFi
            builder.SetTrigger(new TimeTrigger(15, false));
            builder.AddCondition(new SystemCondition(SystemConditionType.FreeNetworkAvailable));
            builder.AddCondition(new SystemCondition(SystemConditionType.BackgroundWorkCostNotHigh));

            builder.Register();
            Debug.WriteLine("[Resonance] Background sync task registered.");
        }

        // =====================================================================
        // Helpers
        // =====================================================================

        private string GetDeviceId()
        {
            var settings = ApplicationData.Current.LocalSettings;
            if (settings.Values.TryGetValue("DeviceId", out var id) && id is string deviceId)
                return deviceId;

            deviceId = Guid.NewGuid().ToString("N")[..16];
            settings.Values["DeviceId"] = deviceId;
            return deviceId;
        }

        public void Dispose()
        {
            if (_isDisposed) return;
            _isDisposed = true;

            _syncCts?.Cancel();
            _syncTimer?.Dispose();
            _signalRManager?.Dispose();
            _httpClient?.Dispose();
            _biometricMonitor?.Stop();
        }
    }

    // =========================================================================
    // Local Storage Service (SQLite with Encryption)
    // =========================================================================

    /// <summary>
    /// Encrypted local storage using SQLite.
    /// Health data (biomarkers, protocols) receives additional AES-256 encryption.
    /// </summary>
    public class LocalStorageService
    {
        private readonly string _dbPath;
        private readonly string _encryptionKeyId;
        private byte[] _encryptionKey;

        public LocalStorageService(string dbPath, string encryptionKeyId)
        {
            _dbPath = dbPath;
            _encryptionKeyId = encryptionKeyId;
        }

        public async Task InitializeAsync()
        {
            // Derive encryption key from device credentials
            _encryptionKey = await DeriveEncryptionKeyAsync();

            // In production: create SQLite tables via Microsoft.Data.Sqlite
            // Tables: tasks, phases, contacts, messages, documents,
            //         writing_sessions, patients, providers, biomarkers,
            //         protocols, sync_log
            Debug.WriteLine($"[Resonance] Local storage initialized at: {_dbPath}");
        }

        public async Task<List<SyncChange>> GetChangesSinceAsync(DateTime since)
        {
            // Query sync_log table for changes since the given timestamp
            await Task.CompletedTask;
            return new List<SyncChange>();
        }

        public async Task ApplyChangesAsync(List<SyncChange> changes)
        {
            foreach (var change in changes)
            {
                // Determine if this is health data that needs extra encryption
                bool isHealthData = change.EntityType is "Biomarker" or "Protocol" or "Patient";

                if (isHealthData)
                {
                    change.Data = EncryptHealthData(change.Data);
                }

                // Upsert into appropriate table
                Debug.WriteLine($"[Resonance] Applying change: {change.EntityType}/{change.EntityId}");
            }
            await Task.CompletedTask;
        }

        private string EncryptHealthData(string plainText)
        {
            if (_encryptionKey == null || string.IsNullOrEmpty(plainText))
                return plainText;

            using var aes = Aes.Create();
            aes.Key = _encryptionKey;
            aes.GenerateIV();

            using var encryptor = aes.CreateEncryptor();
            var plainBytes = Encoding.UTF8.GetBytes(plainText);
            var encrypted = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);

            // Prepend IV for decryption
            var result = new byte[aes.IV.Length + encrypted.Length];
            Buffer.BlockCopy(aes.IV, 0, result, 0, aes.IV.Length);
            Buffer.BlockCopy(encrypted, 0, result, aes.IV.Length, encrypted.Length);

            return Convert.ToBase64String(result);
        }

        private string DecryptHealthData(string cipherText)
        {
            if (_encryptionKey == null || string.IsNullOrEmpty(cipherText))
                return cipherText;

            var cipherBytes = Convert.FromBase64String(cipherText);

            using var aes = Aes.Create();
            aes.Key = _encryptionKey;

            // Extract IV from beginning
            var iv = new byte[aes.BlockSize / 8];
            Buffer.BlockCopy(cipherBytes, 0, iv, 0, iv.Length);
            aes.IV = iv;

            using var decryptor = aes.CreateDecryptor();
            var decrypted = decryptor.TransformFinalBlock(
                cipherBytes, iv.Length, cipherBytes.Length - iv.Length);

            return Encoding.UTF8.GetString(decrypted);
        }

        private async Task<byte[]> DeriveEncryptionKeyAsync()
        {
            // In production: use Windows DPAPI or Azure Key Vault
            // For now, derive from a machine-specific seed
            await Task.CompletedTask;
            var seed = $"resonance-{Environment.MachineName}-{_encryptionKeyId ?? "default"}";
            using var sha = SHA256.Create();
            return sha.ComputeHash(Encoding.UTF8.GetBytes(seed));
        }
    }

    // =========================================================================
    // Calm Notification Service
    // =========================================================================

    /// <summary>
    /// Notifications in Resonance are calm and non-aggressive.
    /// No red badges. No urgent sounds. Just gentle, timely information.
    /// </summary>
    public class CalmNotificationService
    {
        /// <summary>
        /// Show a gentle notification that doesn't demand immediate attention.
        /// </summary>
        public void ShowCalm(string title, string message, CalmNotificationLevel level = CalmNotificationLevel.Info)
        {
            var template = level switch
            {
                CalmNotificationLevel.Info => CreateInfoNotification(title, message),
                CalmNotificationLevel.Milestone => CreateMilestoneNotification(title, message),
                CalmNotificationLevel.PhaseChange => CreatePhaseChangeNotification(title, message),
                CalmNotificationLevel.Reminder => CreateReminderNotification(title, message),
                _ => CreateInfoNotification(title, message)
            };

            try
            {
                var notification = new ToastNotification(template)
                {
                    ExpirationTime = DateTimeOffset.Now.AddMinutes(30),
                    Priority = ToastNotificationPriority.Default,
                    SuppressPopup = level == CalmNotificationLevel.Info // Info notifications go silently to Action Center
                };

                ToastNotificationManager
                    .CreateToastNotifier()
                    .Show(notification);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Resonance] Notification error: {ex.Message}");
            }
        }

        private Windows.Data.Xml.Dom.XmlDocument CreateInfoNotification(string title, string message)
        {
            var xml = $@"
                <toast>
                    <visual>
                        <binding template='ToastGeneric'>
                            <text>{EscapeXml(title)}</text>
                            <text>{EscapeXml(message)}</text>
                        </binding>
                    </visual>
                    <audio silent='true' />
                </toast>";
            var doc = new Windows.Data.Xml.Dom.XmlDocument();
            doc.LoadXml(xml);
            return doc;
        }

        private Windows.Data.Xml.Dom.XmlDocument CreateMilestoneNotification(string title, string message)
        {
            var xml = $@"
                <toast>
                    <visual>
                        <binding template='ToastGeneric'>
                            <text hint-style='header'>{EscapeXml(title)}</text>
                            <text>{EscapeXml(message)}</text>
                        </binding>
                    </visual>
                    <audio src='ms-appx:///Assets/Sounds/milestone.wav' />
                </toast>";
            var doc = new Windows.Data.Xml.Dom.XmlDocument();
            doc.LoadXml(xml);
            return doc;
        }

        private Windows.Data.Xml.Dom.XmlDocument CreatePhaseChangeNotification(string title, string message)
        {
            var xml = $@"
                <toast scenario='reminder'>
                    <visual>
                        <binding template='ToastGeneric'>
                            <text>{EscapeXml(title)}</text>
                            <text>{EscapeXml(message)}</text>
                        </binding>
                    </visual>
                    <actions>
                        <action content='Acknowledge' arguments='phase-ack' />
                        <action content='Snooze' arguments='phase-snooze' />
                    </actions>
                    <audio silent='true' />
                </toast>";
            var doc = new Windows.Data.Xml.Dom.XmlDocument();
            doc.LoadXml(xml);
            return doc;
        }

        private Windows.Data.Xml.Dom.XmlDocument CreateReminderNotification(string title, string message)
        {
            var xml = $@"
                <toast>
                    <visual>
                        <binding template='ToastGeneric'>
                            <text>{EscapeXml(title)}</text>
                            <text>{EscapeXml(message)}</text>
                        </binding>
                    </visual>
                    <audio silent='true' />
                </toast>";
            var doc = new Windows.Data.Xml.Dom.XmlDocument();
            doc.LoadXml(xml);
            return doc;
        }

        private static string EscapeXml(string text) =>
            text?.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;") ?? "";
    }

    public enum CalmNotificationLevel
    {
        Info,
        Milestone,
        PhaseChange,
        Reminder
    }

    // =========================================================================
    // Biometric Monitor Service
    // =========================================================================

    /// <summary>
    /// Background service that monitors health device data (if authorized).
    /// Designed to be power-efficient and privacy-respecting.
    /// </summary>
    public class BiometricMonitorService
    {
        private readonly TimeSpan _pollInterval;
        private Timer _pollTimer;
        private bool _isRunning;

        public event EventHandler<BiometricReading> NewReading;

        public BiometricMonitorService(TimeSpan pollInterval)
        {
            _pollInterval = pollInterval;
        }

        public void Start()
        {
            if (_isRunning) return;
            _isRunning = true;

            _pollTimer = new Timer(async _ => await PollDevicesAsync(), null, TimeSpan.Zero, _pollInterval);
            Debug.WriteLine("[Resonance] Biometric monitor started.");
        }

        public void Stop()
        {
            _isRunning = false;
            _pollTimer?.Dispose();
            Debug.WriteLine("[Resonance] Biometric monitor stopped.");
        }

        private async Task PollDevicesAsync()
        {
            try
            {
                // In production: query Windows Health platform APIs
                // or connected Bluetooth LE devices (heart rate, SpO2, etc.)
                await Task.CompletedTask;
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Resonance] Biometric poll error: {ex.Message}");
            }
        }
    }

    public class BiometricReading
    {
        public string DeviceId { get; set; }
        public string MetricType { get; set; }
        public double Value { get; set; }
        public string Unit { get; set; }
        public DateTime Timestamp { get; set; }
    }

    // =========================================================================
    // SignalR Connection Manager
    // =========================================================================

    /// <summary>
    /// Manages the SignalR WebSocket connection for real-time data sync.
    /// Handles reconnection gracefully — no error spam to the user.
    /// </summary>
    public class SignalRConnectionManager : IDisposable
    {
        private readonly string _hubUrl;
        private bool _isConnected;
        private int _reconnectAttempts;
        private Timer _reconnectTimer;

        public bool IsConnected => _isConnected;
        public event EventHandler<DataChangedEventArgs> DataChanged;
        public event EventHandler<bool> ConnectionStatusChanged;

        public SignalRConnectionManager(string hubUrl)
        {
            _hubUrl = hubUrl;
        }

        public async Task ConnectAsync()
        {
            try
            {
                // In production: use Microsoft.AspNetCore.SignalR.Client
                // var connection = new HubConnectionBuilder()
                //     .WithUrl(_hubUrl)
                //     .WithAutomaticReconnect(new[] { 0, 2, 10, 30, 60 }.Select(s => TimeSpan.FromSeconds(s)).ToArray())
                //     .Build();

                _isConnected = true;
                _reconnectAttempts = 0;
                ConnectionStatusChanged?.Invoke(this, true);

                Debug.WriteLine($"[Resonance] SignalR connected to: {_hubUrl}");
                await Task.CompletedTask;
            }
            catch (Exception ex)
            {
                _isConnected = false;
                ConnectionStatusChanged?.Invoke(this, false);
                Debug.WriteLine($"[Resonance] SignalR connection failed: {ex.Message}");
                ScheduleReconnect();
            }
        }

        private void ScheduleReconnect()
        {
            _reconnectAttempts++;
            var delay = TimeSpan.FromSeconds(Math.Min(60, Math.Pow(2, _reconnectAttempts)));

            _reconnectTimer = new Timer(async _ =>
            {
                Debug.WriteLine($"[Resonance] SignalR reconnect attempt #{_reconnectAttempts}");
                await ConnectAsync();
            }, null, delay, Timeout.InfiniteTimeSpan);
        }

        public void Dispose()
        {
            _reconnectTimer?.Dispose();
            _isConnected = false;
        }
    }

    // =========================================================================
    // Sync Data Transfer Objects
    // =========================================================================

    public class SyncChange
    {
        public string EntityId { get; set; }
        public string EntityType { get; set; }
        public string Data { get; set; }
        public DateTime Timestamp { get; set; }
        public string ChangeType { get; set; } // "create", "update", "delete"
        public bool WasConflict { get; set; }
    }

    public class SyncPushPayload
    {
        public string DeviceId { get; set; }
        public List<SyncChange> Changes { get; set; }
        public DateTime Timestamp { get; set; }
    }

    public class SyncPushResult
    {
        public bool Success { get; set; }
        public string Error { get; set; }
        public int AcceptedCount { get; set; }
    }

    public class SyncPullResult
    {
        public List<SyncChange> Changes { get; set; }
        public DateTime ServerTime { get; set; }
    }

    public class SyncCompletedEventArgs : EventArgs
    {
        public int PushedCount { get; set; }
        public int PulledCount { get; set; }
        public int ConflictsResolved { get; set; }
        public DateTime SyncTime { get; set; }
    }

    public class SyncErrorEventArgs : EventArgs
    {
        public Exception Error { get; set; }
        public bool IsRecoverable { get; set; }
    }

    public class DataChangedEventArgs : EventArgs
    {
        public string EntityId { get; set; }
        public string EntityType { get; set; }
        public string Data { get; set; }
        public string SourceDeviceId { get; set; }
    }
}
