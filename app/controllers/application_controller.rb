class ApplicationController < ActionController::Base
   # Installing pagy  
  include Pagy::Backend
    before_action :turbo_frame_request_variant
    before_action :set_current_user
    before_action :validate_username
  
    private
    # The turbo frame variant is used to optimize performance for requests made with Turbo Frame,
    # a technique for improving the performance of web applications by reducing the amount of data
    # that needs to be transmitted between the server and the browser.
    #
    # This method is called before each action in the ApplicationController, and it checks whether
    # the current request is a turbo frame request. If it is, it sets the request variant to :turbo_frame,
    # which will cause the response to be rendered using the Turbo Frame format.
    def turbo_frame_request_variant
      request.variant = :turbo_frame if turbo_frame_request?
    end

    def set_current_user
      Current.user = current_user
    end

    def validate_username
      return if current_user.nil?

      return if request.path.include?("/users")

      if current_user.username.blank?
        redirect_to edit_user_registration_path, alert: "Username can't be blank"
      end
    end
    
  end
  