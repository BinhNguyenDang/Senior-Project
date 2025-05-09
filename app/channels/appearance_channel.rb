class AppearanceChannel < ApplicationCable::Channel
  # Subscribes to the Appearance channel when a client connects.
  # This method is called automatically when a client subscribes to the channel.
  def subscribed
    stream_from 'appearance_channel'
    online
  end

  # Unsubscribes from the Appearance channel when a client disconnects.
  # This method is called automatically when a client unsubscribes from the channel.
  def unsubscribed
    stop_stream_from 'appearance_channel'
    offline
  end

  # Sets the user's status to online and broadcasts the new status to all subscribers.
  def online
    status = User.statuses[:online]
    broadcast_new_status(status)
  end

  # Sets the user's status to offline and broadcasts the new status to all subscribers.
  def offline
    status = User.statuses[:offline]
    broadcast_new_status(status)
  end

  # Sets the user's status to away and broadcasts the new status to all subscribers.
  def away
    status = User.statuses[:away]
    broadcast_new_status(status)
  end

  # Receives data from the client and broadcasts it to all subscribers.
  # Mainlt to catch edge cases.
  def receive(data)
    ActionCable.server.broadcast('appearance_channel', data)
  end

  private

  # Updates the current user's status and broadcasts the new status to all subscribers.
  def broadcast_new_status(status)
    target_user = User.find_by(id: current_user.id)
    current_user.update!(status: status) unless target_user.dnd?
  end
end
