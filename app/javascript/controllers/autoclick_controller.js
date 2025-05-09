import { Controller } from '@hotwired/stimulus';
import { useIntersection } from 'stimulus-use';

export default class Autoclick extends Controller {
  static messagesContainer;
  static topMessage;
  static throttling = false;
    /**
   * Connects the controller to the element and initializes the intersection observer.
   */
  connect() {
    console.log('connected to Autoclick');
    /**
     * Adds an intersection observer to the element that triggers the appear and disappear methods when the element enters or leaves the viewport.
     * @param {Controller} controller - The controller instance that is being observed.
     */
    useIntersection(this);
  }

  /**
 * Callback function automatically triggered when the element
 * intersects with the viewport (or root Element specified in the options)
 * @param {IntersectionObserverEntry} entry - An object that provides information about the intersection between the target element and the root element or the top of the viewport
 * @param {IntersectionObserver} observer - A reference to the IntersectionObserver instance
 */
  appear(entry, observer) {
    // Check if throttling is active
    if (!Autoclick.throttling) {
      // Set throttling to active
      Autoclick.throttling = true;

      // Get the messages container and the top message
      Autoclick.messagesContainer = document.getElementById('messages-container');
      Autoclick.topMessage = Autoclick.messagesContainer.children[0];

      // Throttle the click function
      Autoclick.throttle(this.element.click(),300);

      // Scroll to the top message after 250ms
      setTimeout(() => {
        Autoclick.topMessage.scrollIntoView({ behavior:"auto", block: "end" });
        console.log("Scrolling");
        // Set throttling to inactive
        Autoclick.throttling = false;
      }, 250);
    }
  }

  disappear(entry, observer) {
    // callback automatically triggered when the element
    // leaves the viewport (or root Element specified in the options)
  }


  /**
 * Throttle a function
 * @param {Function} func - The function to be throttled
 * @param {Number} wait - The time to wait before executing the function again
 */
  static throttle(func, wait) {
    let timeout = null ;
    let previous = 0 ;

    let later = function() {
      previous = Date.now();
      timeout = null ;
      func();
    };
    return function() {
      let now = Date.now();
      let remaining = wait - (now - previous);

      // If the remaining time is zero or negative (indicating that the wait time has passed),
      // or if remaining is greater than the wait time (to handle clock adjustments),
      // execute the function immediately
      if(remaining <= 0 || remaining > wait) {
        if(timeout) {
          clearTimeout(timeout);
        }
        later();
      // If there is no timeout set and the remaining time is positive,
      // set a new timeout to call the function after the remaining time has elapsed
      } else if (!timeout) {
        timeout = setTimeout(later, remaining);
      }
    };
  }
}