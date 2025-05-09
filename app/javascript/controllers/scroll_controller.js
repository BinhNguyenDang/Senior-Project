import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    initialize() {
        console.log("Initialized");
        // Get the messages container element
        this.messages = document.getElementById("messages");
        // Reset scroll position to the bottom of the messages container
        this.resetScrollWithoutThreshold(this.messages);
    }
    /** On start */
    connect(){
        console.log("Connected Scroll");
        
        // Create an observer instance linked to the resetScroll method
        this.observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                if (mutation.type === 'childList') {
                    this.resetScroll();
                }
            });
        });
        
        // Start observing the target node for configured mutations
        this.observer.observe(this.messages, {
            childList: true, // Observe direct children additions and removals
            subtree: false, // Do not observe all descendants, just direct children
        });
    }
    /** On stop */
    disconnect(){
        console.log("Disconnected");
        // Disconnect the observer when the controller is disconnected
        this.observer.disconnect();
    }
    /** Custom function to reset scroll position */
    resetScroll(){
        const bottomOfScroll = this.messages.scrollHeight - this.messages.clientHeight;
        // if the user's scroll position is above this threshold (200 pixels), the controller will not automatically scroll to the bottom.
        const upperScrollThreshold = bottomOfScroll - 1000;
        // Scroll down if we're not within the threshold
        if (this.messages.scrollTop > upperScrollThreshold){
            this.messages.scrollTop = this.messages.scrollHeight - this.messages.clientHeight;
        }
        const audio_tag = document.getElementById("audio-tag");
        audio_tag.play();

    }
    /** Function to reset scroll position without considering a threshold */
    resetScrollWithoutThreshold(messages){
        messages.scrollTop = messages.scrollHeight - messages.clientHeight;
    }
}
