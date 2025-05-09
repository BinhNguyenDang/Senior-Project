class AdminController < ApplicationController
  def dashboard
    if (current_user&.admin?)
      @messages = Message.messages_this_month
    else
      redirect_to root_path
      flash[:error] = "You are not authorized to access the admin dashboard"
    end
  end
end
