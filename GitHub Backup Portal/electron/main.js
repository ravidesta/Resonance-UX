const { app, BrowserWindow, Menu, ipcMain, dialog, shell } = require('electron');
const path = require('path');
const { exec } = require('child_process');
const fs = require('fs');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1024,
    minHeight: 700,
    titleBarStyle: 'hiddenInset',
    backgroundColor: '#0A1C14',
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
    icon: path.join(__dirname, '../public/icon.ico'),
  });

  const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged;
  if (isDev) {
    mainWindow.loadURL('http://localhost:3000');
  } else {
    mainWindow.loadFile(path.join(__dirname, '../build/index.html'));
  }
}

// Server command handlers
const serverCommands = {
  'kopia:status': 'kopia repository status',
  'kopia:snapshot-list': 'kopia snapshot list',
  'kopia:snapshot-create': 'kopia snapshot create',
  'kopia:policy-show': 'kopia policy show',
  'kopia:maintenance': 'kopia maintenance run',
  'kopia:connect': 'kopia repository connect',
  'kopia:disconnect': 'kopia repository disconnect',
  'git:status': 'git status',
  'git:log': 'git log --oneline -20',
  'git:fetch': 'git fetch --all',
  'git:clone': (args) => `git clone ${args}`,
};

// File menu template
const menuTemplate = [
  {
    label: 'File',
    submenu: [
      {
        label: 'New Portfolio',
        accelerator: 'CmdOrCtrl+N',
        click: () => mainWindow.webContents.send('menu:new-portfolio'),
      },
      {
        label: 'Import Repository',
        accelerator: 'CmdOrCtrl+I',
        click: () => mainWindow.webContents.send('menu:import-repo'),
      },
      { type: 'separator' },
      {
        label: 'Kopia: Repository Status',
        click: () => executeServerCommand('kopia:status'),
      },
      {
        label: 'Kopia: List Snapshots',
        click: () => executeServerCommand('kopia:snapshot-list'),
      },
      {
        label: 'Kopia: Create Snapshot',
        click: () => executeServerCommand('kopia:snapshot-create'),
      },
      {
        label: 'Kopia: Show Policies',
        click: () => executeServerCommand('kopia:policy-show'),
      },
      {
        label: 'Kopia: Run Maintenance',
        click: () => executeServerCommand('kopia:maintenance'),
      },
      { type: 'separator' },
      {
        label: 'Git: Fetch All',
        click: () => executeServerCommand('git:fetch'),
      },
      {
        label: 'Git: Status',
        click: () => executeServerCommand('git:status'),
      },
      { type: 'separator' },
      {
        label: 'Generate PDF Report',
        accelerator: 'CmdOrCtrl+P',
        click: () => mainWindow.webContents.send('menu:generate-report'),
      },
      { type: 'separator' },
      {
        label: 'Settings',
        accelerator: 'CmdOrCtrl+,',
        click: () => mainWindow.webContents.send('menu:settings'),
      },
      { type: 'separator' },
      { role: 'quit' },
    ],
  },
  {
    label: 'Server',
    submenu: [
      {
        label: 'Connect to Kopia Server',
        click: () => mainWindow.webContents.send('menu:kopia-connect'),
      },
      {
        label: 'Disconnect from Kopia',
        click: () => executeServerCommand('kopia:disconnect'),
      },
      { type: 'separator' },
      {
        label: 'Start Local Server',
        click: () => executeServerCommand('kopia:server-start'),
      },
      {
        label: 'Server Dashboard',
        click: () => shell.openExternal('http://localhost:51515'),
      },
    ],
  },
  {
    label: 'View',
    submenu: [
      {
        label: 'Gallery Mode',
        accelerator: 'CmdOrCtrl+1',
        click: () => mainWindow.webContents.send('menu:view-gallery'),
      },
      {
        label: 'Calendar Ledger',
        accelerator: 'CmdOrCtrl+2',
        click: () => mainWindow.webContents.send('menu:view-calendar'),
      },
      {
        label: 'Database View',
        accelerator: 'CmdOrCtrl+3',
        click: () => mainWindow.webContents.send('menu:view-database'),
      },
      { type: 'separator' },
      {
        label: 'Deep Rest Mode',
        accelerator: 'CmdOrCtrl+D',
        click: () => mainWindow.webContents.send('menu:toggle-dark'),
      },
      { type: 'separator' },
      { role: 'reload' },
      { role: 'toggleDevTools' },
      { role: 'togglefullscreen' },
    ],
  },
  {
    label: 'Help',
    submenu: [
      {
        label: 'Kopia Documentation',
        click: () => shell.openExternal('https://kopia.io/docs/'),
      },
      {
        label: 'AppFlowy Documentation',
        click: () => shell.openExternal('https://docs.appflowy.io/'),
      },
    ],
  },
];

function executeServerCommand(cmdKey) {
  const cmd = serverCommands[cmdKey];
  if (!cmd) return;
  const command = typeof cmd === 'function' ? cmd('') : cmd;
  exec(command, (error, stdout, stderr) => {
    mainWindow.webContents.send('server:output', {
      command: cmdKey,
      stdout: stdout || '',
      stderr: stderr || '',
      error: error ? error.message : null,
    });
  });
}

ipcMain.handle('execute-command', async (event, command) => {
  return new Promise((resolve) => {
    exec(command, (error, stdout, stderr) => {
      resolve({ stdout, stderr, error: error ? error.message : null });
    });
  });
});

ipcMain.handle('select-directory', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory'],
  });
  return result.filePaths[0] || null;
});

app.whenReady().then(() => {
  const menu = Menu.buildFromTemplate(menuTemplate);
  Menu.setApplicationMenu(menu);
  createWindow();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
