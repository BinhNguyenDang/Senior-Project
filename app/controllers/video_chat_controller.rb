class VideoChatController < ApplicationController
  before_action :authenticate_user!
  def index
    @room = Room.find(params[:id])
    @user = current_user
  end
end
