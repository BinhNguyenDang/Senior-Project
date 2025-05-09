class UsersController < ApplicationController
  include RoomsHelper
  before_action :set_user, only: [:show, :profile]
  def show
    # Find the user by ID
    # @user = User.find(params[:id])
    
    # Get all users except the current user (custom scope in user.rb)
    @users = User.all_except(current_user)

    # Initialize a new room
    @room = Room.new

    # Fetch rooms that the current user has joined
    @joined_rooms = current_user.joined_rooms
    
    # Fetch public rooms (custom scope in room.rb)
    # @rooms = Room.public_rooms
    
    # Search for public rooms
    @rooms = search_rooms

    # Generate or find the private room between current user and the user whose profile is being viewed
    @room_name = get_name(@user, current_user)
    # Find a room with the specified name in the database, or create a new private room (function in room.rb) if it doesn't exist
    @single_room = Room.where(name: @room_name).first || Room.create_private_room([@user, current_user], @room_name)

    current_user.update(current_room: @single_room)
    # Initialize a new message
    @message = Message.new
    
    # Fetch messages for the single room, ordered by creation time
    # @messages = @single_room.messages.order(created_at: :asc)
    pagy_messages = @single_room.messages.includes(:user).order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 10)
    @messages = messages.reverse
    
    # Render the 'rooms/index' template
    render 'rooms/index'
  end

  def search
    if params[:username_query]
      @users = User.where('username ILIKE ?', "%#{params[:username_query]}%")
      render json: @users, only: [:id, :username] # Customize as needed
    else
      render json: []
    end
  end

  def profile
    # @user = User.find(params[:id])
    @dashboard = @user.messages.group_by_day(:created_at, range: 1.month.ago..Time.now).count
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end
  
  
end
