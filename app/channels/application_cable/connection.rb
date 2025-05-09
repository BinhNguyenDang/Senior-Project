module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # Identifies the connection by the current user.
    # This line declares the identifier `current_user`, which is used to track the user associated with the connection.
    # ActionCable does not have access to devise user by default, so we need to add this line.
    identified_by :current_user
    
    # Establishes a connection and identifies the current user.
    def connect 
      self.current_user = find_verified_user
    end

    private
    # Finds and verifies the current user.
    # If the user is authenticated, returns the user object.
    # Otherwise, rejects the unauthorized connection
    # If the user is authenticated (verified_user = env['warden'].user), it returns the user object
    def find_verified_user
      if verified_user = env['warden'].user
        verified_user
      else
        reject_unauthorized_connection
      end
    end
    
  end
end
