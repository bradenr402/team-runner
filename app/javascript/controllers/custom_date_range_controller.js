import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="custom-date-range"
export default class extends Controller {
  static targets = [
    'select',
    'startDate',
    'endDate',
    'startDateField',
    'endDateField',
  ];

  update(event) {
    if (this.selectTarget.value === 'Custom range')
      this.showCustomRangeFields();
    else this.hideCustomRangeFields();
  }

  showCustomRangeFields() {
    this.startDateTarget.classList.remove('hidden');
    this.endDateTarget.classList.remove('hidden');
  }

  hideCustomRangeFields() {
    this.startDateTarget.classList.add('hidden');
    this.endDateTarget.classList.add('hidden');
  }

  search() {
    if (this.selectTarget.value === 'Custom range') {
      const startDate = Date.parse(this.startDateFieldTarget.value);
      const endDate = Date.parse(this.endDateFieldTarget.value);
      const today = new Date();

      if (
        this.startDateFieldTarget.value &&
        this.endDateFieldTarget.value &&
        startDate >= endDate &&
        endDate >= today
      ) {
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => this.element.requestSubmit(), 200);
      }
    } else this.element.requestSubmit();
  }
}
