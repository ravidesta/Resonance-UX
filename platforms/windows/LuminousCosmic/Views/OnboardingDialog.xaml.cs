using Microsoft.UI.Xaml.Controls;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// Onboarding dialog for collecting birth data to calculate the natal chart.
/// </summary>
public sealed partial class OnboardingDialog : ContentDialog
{
    public BirthData? BirthData { get; private set; }

    public OnboardingDialog()
    {
        this.InitializeComponent();

        // Set default birth time to noon
        BirthTimePicker.SelectedTime = new TimeSpan(12, 0, 0);
    }

    private void OnPrimaryButtonClick(ContentDialog sender, ContentDialogButtonClickEventArgs args)
    {
        // Validate inputs
        if (string.IsNullOrWhiteSpace(NameInput.Text))
        {
            args.Cancel = true;
            NameInput.Focus(Microsoft.UI.Xaml.FocusState.Programmatic);
            return;
        }

        if (BirthDatePicker.Date == null)
        {
            args.Cancel = true;
            BirthDatePicker.Focus(Microsoft.UI.Xaml.FocusState.Programmatic);
            return;
        }

        // Build birth data
        BirthData = new BirthData
        {
            Name = NameInput.Text.Trim(),
            BirthDate = BirthDatePicker.Date.Value.DateTime,
            BirthTime = BirthTimePicker.SelectedTime ?? new TimeSpan(12, 0, 0),
            BirthCity = BirthCityInput.Text?.Trim() ?? "",
            Latitude = LatitudeInput.Value,
            Longitude = LongitudeInput.Value,
            TimezoneOffset = TimezoneInput.Value
        };
    }
}
