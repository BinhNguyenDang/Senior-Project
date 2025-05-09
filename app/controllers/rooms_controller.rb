class RoomsController < ApplicationController
include RoomsHelper
  # Ensure that the user is authenticated before executing any action
  before_action :authenticate_user!
  before_action :set_status
  before_action :authorize_user, only: [:show]
  before_action :set_room, only: [:join, :leave]
  
  
  def index
    # Initialize a new instance of the Room model
    @rooms = Room.new

    # Retrieve rooms that the current user has joined
    @joined_rooms = current_user.joined_rooms.order("last_message_at DESC")

    current_user.update(current_room: nil)

    # Retrieve public rooms using the public_rooms scope (definition in room.rb)
    # @rooms = Room.public_rooms

    # Search for public rooms using the search_rooms helper method
    @rooms = search_rooms
    
    # Fetch all users except the current user, all_except scope ( definition in user.rb)
    @users = User.all_except(current_user)

    # @notifications = current_user.notifications.includes(event: :record)
    
    
    # Render the 'index' template
    render 'index'
  end
  
  def show
    # Find the room with the specified ID
    @single_room = Room.find(params[:id])
    
    # @counter = unread
    
    set_notifications_to_read
    # Initialize a new instance of the Room model
    @rooms = Room.new

    # Retrieve public rooms using the public_rooms scope
    # @rooms = Room.public_rooms

    # Search for public rooms using the search_rooms helper method
    @rooms = search_rooms

    # Retrieve rooms that the current user has joined
    @joined_rooms = current_user.joined_rooms.order("last_message_at DESC")

    current_user.update(current_room: @single_room)

    
    
    # Initialize a new instance of the Message model
    @message = Message.new
    
    # Fetch messages associated with the single room
    # @messages = @single_room.messages.order(created_at: :asc)

    # Fetch messages belonging to a single room, including associated users and ordering them by creation time in descending order
    pagy_messages = @single_room.messages.includes(:user).order(created_at: :desc)
    # Paginate the fetched messages, displaying 10 messages per page, and store pagination metadata in @pagy
    # The paginated messages for the current page are stored in the variable `messages`
    @pagy, messages = pagy(pagy_messages, items: 10)
    # Reverse the order of messages to display the most recent messages at the top
    @messages = messages.reverse
    
    
    # Fetch all users except the current user
    @users = User.all_except(current_user)
    
    # Render the 'index' template
    render 'index'

    rescue ActiveRecord::RecordNotFound
      redirect_to rooms_path, alert: "Room not found."
  
  end
  
  def create
    # Access the name parameter correctly using strong parameters
    @room = Room.create(room_params)
  
    if @room.persisted?
      # Redirects the user to the show page of the newly created room
      redirect_to @room, notice: 'Room was successfully created.'
    else
      # If the room was not created successfully, render the form again with errors
      flash.now[:alert] = 'There was an error creating the room.'
      render 'index', status: :unprocessable_entity
    end
  end

  def search
    # Calls the search_rooms helper method to search for rooms
    @rooms = search_rooms
    respond_to do |format|
      format.turbo_stream do
        # Responds with Turbo Stream format
        # Updates the 'search_results' element with the search results
        render turbo_stream: [
          turbo_stream.update('search_results', 
                              partial: 'rooms/search_results', 
                              locals: { rooms: @rooms})
      ]
      end
    end
  end


  def join
    # Finds the room with the specified ID
    # Adds the current user to the joined_rooms association of the room
    current_user.joined_rooms << @room
    # Redirects to the rooms index page
    redirect_to rooms_path
  end

  def leave
    # Finds the room with the specified ID
    # Removes the current user from the joined_rooms association of the room
    current_user.joined_rooms.delete(@room)
    # Redirects to the rooms index page
    redirect_to rooms_path
  end


  private
  # Set the user's status to 'online' before any action
  def set_status
    return if current_user.dnd?
    current_user.update!(status: User.statuses[:online]) if current_user
  end

  def set_notifications_to_read
    current_room_id = params[:id].to_i
    return unless current_room_id.present?
    
    # Fetch all unread notifications for the current_user that are associated with the current room
    # It leverages the direct relationship between the notification's event (record_id) and the room_id
    unread_notifications = current_user.notifications.joins(:event)
                                    .where(noticed_events: { record_id: current_room_id, record_type: 'Room' })
                                    .unread
    
    # Bulk update to mark notifications as read
    unread_notifications.update_all(read_at: Time.current)
  end

  def set_room
    @room = Room.find(params[:id])
  end

  def authorize_user
    
    @room = Room.find(params[:id])
    if @room.is_private
      unless @room.participant?(@room, current_user)
        redirect_to rooms_path, alert: "You are not a member of this room."
      end
    end
    rescue ActiveRecord::RecordNotFound
      redirect_to rooms_path, alert: "Room not found."
  end


  def room_params
    params.require(:room).permit(:name)
  end 
end
