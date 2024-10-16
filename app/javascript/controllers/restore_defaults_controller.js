import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="restore-defaults"
export default class extends Controller {
  static targets = [
    'emailVisible',
    'phoneVisible',
    'theme',
    'inApp',
    'requireGender',
    'maxAllowedRequests',
    'longRunDistanceMale',
    'longRunDistanceFemale',
    'longRunDistanceNeutral',
    'weekStart',
    'includeSaturday',
    'includeSunday',
  ];

  connect() {
    // Default settings
    // Refer to [user_settings.rb](/app/models/user_settings.rb) and [team_settings.rb](/app/models/team_settings.rb) for more info

    this.defaultValues = {
      emailVisible: false,
      phoneVisible: false,
      theme: 'system',
      inApp: true,
      requireGender: false,
      maxAllowedRequests: 3,
      longRunDistanceMale: 8,
      longRunDistanceFemale: 6,
      longRunDistanceNeutral: 7,
      weekStart: 'monday',
      includeSaturday: false,
      includeSunday: false,
      streakMale: 2,
      streakFemale: 2,
      streakNeutral: 2,
    };
  }

  restore() {
    this.restoreUserSettings();
    this.restoreTeamSettings();

    // Submit the form
    this.element.submit();
  }

  restoreUserSettings() {
    // Restore default values for user settings form
    if (this.hasEmailVisibleTarget)
      this.emailVisibleTarget.checked = this.defaultValues.emailVisible;

    if (this.hasPhoneVisibleTarget)
      this.phoneVisibleTarget.checked = this.defaultValues.phoneVisible;

    if (this.hasThemeTarget) {
      this.themeTarget.value = this.defaultValues.theme;
      this.themeTarget.dispatchEvent(new Event('change'));
    }

    if (this.hasInAppTarget)
      this.inAppTarget.checked = this.defaultValues.inApp;
  }

  restoreTeamSettings() {
    // Restore default values for team settings form
    if (this.hasRequireGenderTarget) {
      this.requireGenderTarget.checked = this.defaultValues.requireGender;

      // Show/hide long run distance fields with [team_gender_fields_controller](./team_gender_fields_controller.js)
      this.requireGenderTarget.dispatchEvent(new Event('change'));
    }

    if (this.hasMaxAllowedRequestsTarget)
      this.maxAllowedRequestsTarget.value =
        this.defaultValues.maxAllowedRequests;

    if (this.hasLongRunDistanceMaleTarget)
      this.longRunDistanceMaleTarget.value =
        this.defaultValues.longRunDistanceMale;

    if (this.hasLongRunDistanceFemaleTarget)
      this.longRunDistanceFemaleTarget.value =
        this.defaultValues.longRunDistanceFemale;

    if (this.hasLongRunDistanceNeutralTarget)
      this.longRunDistanceNeutralTarget.value =
        this.defaultValues.longRunDistanceNeutral;

    if (this.hasWeekStartTarget)
      this.weekStartTarget.value = this.defaultValues.weekStart;

    if (this.hasIncludeSaturdayTarget)
      this.includeSaturdayTarget.checked = this.defaultValues.includeSaturday;

    if (this.hasIncludeSundayTarget)
      this.includeSundayTarget.checked = this.defaultValues.includeSunday;

    if (this.hasStreakMaleTarget)
      this.streakMaleTarget.value = this.defaultValues.streakMale;

    if (this.hasStreakFemaleTarget)
      this.streakFemaleTarget.value = this.defaultValues.streakFemale;

    if (this.hasStreakNeutralTarget)
      this.streakNeutralTarget.value = this.defaultValues.streakNeutral;
  }
}
