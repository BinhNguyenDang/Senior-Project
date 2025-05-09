import consumer from "channels/consumer";

let resetFunc;
let timer = 0;

consumer.subscriptions.create("AppearanceChannel", {
  // provide a placeholder for any additional initialization code that may be added in the future. 
  // It is a common practice to include an initialized method in a channel subscription to ensure that any additional initialization code is added to the correct place in the code.
  initialized() {},

  // Called when the subscription is ready for use on the server
  connected() {
    // Log a message to the console
    console.log("Connected");
    // Store the reset function in a variable
    resetFunc = () => this.resetTimer(this.uninstall);
    // Install the appearance tracking functionality
    this.install();
    // Reset the timer when the page is reloaded using Turbo
    window.addEventListener("turbo:load", () => this.resetTimer());
  },

    /**
   * Called when the subscription has been terminated by the server
   */
  disconnected() {
    // Log a message to the console
    console.log("Disconnected");
    // Uninstall the appearance tracking functionality
    this.uninstall();
  },
  rejected() {
    console.log("Rejected");
    this.uninstall();
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  },
    /**
   * Called when the user goes online
   */
  online() {
    console.log("online");
    this.perform("online");
  },
    /**
   * Logs a message to the console when the user goes away
   */
  away() {
    console.log("away");
    this.perform("away");
  },
    /**
   * Logs a message to the console when the user goes offline
   */
  offline(){
    console.log("offline");
    this.perform("offline");
  },
    /**
   * Uninstalls the appearance tracking functionality
   */
  uninstall(){
      const shouldRun = document.getElementById("appearance_channel");
      if(!shouldRun){
        clearTimeout(timer);
        /**
         * Sends the "offline" event to the server
         */
        this.perform("offline");
      }
    },
    /**
   * Installs the appearance tracking functionality
   */
  install(){
      console.log("Install");
      window.removeEventListener("load", resetFunc);
      window.removeEventListener("DOMContentLoaded", resetFunc);
      window.removeEventListener("click", resetFunc);
      window.removeEventListener("keydown", resetFunc);

      window.addEventListener("load", resetFunc);
      window.addEventListener("DOMContentLoaded", resetFunc);
      window.addEventListener("click", resetFunc);
      window.addEventListener("keydown", resetFunc);
      this.resetTimer();
    },
    /**
   * Resets the timer for appearance tracking
   */
  resetTimer() {
    this.uninstall();
    const shouldRun = document.getElementById("appearance_channel");

    if (!!shouldRun) {
      this.online();
      clearTimeout(timer);
      const timeInSecond = 1;
      const milliseconds = 1000;
      const timeInMinutes = timeInSecond *60 * milliseconds;
      // Number of minutes to be delayed
      const numerOfMinutes = 5;
      const timeInMilliseconds = timeInMinutes * numerOfMinutes; 

      timer = setTimeout(this.away.bind(this), timeInMilliseconds);
    }
  }
});
