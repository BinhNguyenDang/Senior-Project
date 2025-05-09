module Turbochat
  class UserStatus < Application
    # This block of code runs after the Rails application has been initialized
    config.after_initialize do
      # Get the connection to the database using ActiveRecord
      connection = ActiveRecord::Base.connection
      
      # Check if the 'users' table exists and if it has a column named 'status'
      if connection.table_exists?('users') && connection.column_exists?('users', 'status')
        # Update all records in the 'users' table, setting the 'status' column to 'offline'
        User.update_all(status: User.statuses[:offline])
      end
      
    rescue StandardError
      # If any error occurs during the process, output a message indicating that user statuses were not updated
      puts 'User statuses not updated'
    end
  end
end
