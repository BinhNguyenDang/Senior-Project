document.addEventListener('DOMContentLoaded', (event) => {
    const chatInput = document.getElementById('chat-text');
    let suggestionBox;
  
    const updateSuggestions = (users) => {
      // Remove existing suggestion box if it exists
      if (suggestionBox) {
        suggestionBox.remove();
      }

      // Create a new suggestion box
      suggestionBox = document.createElement('div');
      suggestionBox.style.position = 'absolute';
      suggestionBox.style.background = 'black';
      suggestionBox.style.color = 'white';
      suggestionBox.style.maxHeight = '80px'; // Set max height for scroll
      suggestionBox.style.overflowY = 'auto'; // Enable vertical scroll
      suggestionBox.style.border = '1px solid #ccc';
      suggestionBox.style.borderRadius = '5px';
      suggestionBox.style.padding = '10px';
      suggestionBox.style.width = chatInput.offsetWidth + 'px';
  
      // Adjust positioning based on input field
      const chatInputRect = chatInput.getBoundingClientRect();
      suggestionBox.style.left = `${chatInputRect.left}px`;
      suggestionBox.style.top = `${chatInputRect.top + window.scrollY - suggestionBox.offsetHeight - 100 }px`;
      
      // Append the suggestion box to the body to avoid being clipped by any parent containers
      document.body.appendChild(suggestionBox);
  
      // Add user suggestions to the box
      users.forEach(user => {
        let userDiv = document.createElement('div');
        userDiv.textContent = user.username;
        userDiv.style.cursor = 'pointer';
        userDiv.onclick = () => selectUser(user.username);
        suggestionBox.appendChild(userDiv);
      });
    };
  
    const selectUser = (username) => {
      const value = chatInput.value;
      const atIndex = value.lastIndexOf("@");
      chatInput.value = value.substring(0, atIndex) + "@" + username + " ";
      if (suggestionBox) {
        suggestionBox.remove();
      }
    };
  
    if (chatInput) {
      chatInput.addEventListener('input', function(e) {
        const value = e.target.value;
        const atIndex = value.lastIndexOf("@");
        if (atIndex !== -1) {
          const query = value.substring(atIndex + 1);
          if (query.length > 0) {
            fetch(`/users/search?username_query=${query}`)
              .then(response => response.json())
              .then(data => {
                updateSuggestions(data); // Use fetched data to display suggestions
              });
          } else if (suggestionBox) {
            // Remove the suggestion box if the query is empty
            suggestionBox.remove();
          }
        }
      });
  
      // Hide suggestions when clicking outside
      document.addEventListener('click', (event) => {
        if (suggestionBox && !chatInput.contains(event.target)) {
          suggestionBox.remove();
        }
      });
    }
  });
