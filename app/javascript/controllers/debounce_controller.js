import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="debounce"
export default class Debounce extends Controller {
  static form = document.getElementById("room_search_form");
  static input = document.getElementById("name_search");
   
  /**
   * Connects to data-controller="debounce"
   */
  connect() {
    console.log("Debounce connected");
    /**
   * Clears the search parameter from the URL if the input field is empty
   * @param {HTMLInputElement} input - The input field
   */
    this.clearParam(Debounce.input);
  }

  search(){
    console.log(" Debouncesearch");
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      Debounce.form.requestSubmit();
    },500);
  }
    /**
   * Clears the search parameter from the URL if the input field is empty
   * @param {HTMLInputElement} input - The input field
   */
  clearParam(input) {
    if (input.value ==="") {
      const baseURL = location.origin + location.pathname;
      window.history.pushState("", "", baseURL);
    }
  }
}
