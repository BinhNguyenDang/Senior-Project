class Message < ApplicationRecord
  # Establishes a belongs_to association with the User model
  belongs_to :user
  
  # Establishes a belongs_to association with the Room model
  belongs_to :room
  has_many_attached :attachments, dependent: :purge_later

  @@not_resizables = %w[image/gif]

  validate :validate_attachment_filetypes

  # Defines a callback to broadcast a message after a new message is created
  #self.room: This refers to the room associated with the message that triggered the callback. 
  #By calling self.room, it retrieves the associated room record.
  after_create_commit do
    notify_recipients
    update_parent_room
    broadcast_append_to self.room 
    broadcast_to_home_page
  end

  # Before creating a new room, confirm the participant
  before_create :confirm_participant


  def chat_attachment(index)
    target = attachments[index]
    return unless attachments.attached?
    return target if @@not_resizables.include?(target.content_type)

    if target.image?
      target.variant(resize_to_limit: [150, 150]).processed
    elsif target.video?
      target.variant(resize_to_limit: [150, 150]).processed
    end
  end

  # Method to confirm if the participant is allowed to create the room
  def confirm_participant
    # Check if the room is private
    return unless room.is_private

    # Check if the user creating the room is a participant
    is_participant = Participant.where(user_id: self.user.id, room_id: self.room.id).first

    # Abort room creation if the user is not a participant
    throw :abort unless is_participant
  end

  def update_parent_room
    room.update(last_message_at: Time.now)
  end

  def owned_by_current_user?
    self.user == Current.user || Current.user.admin? 
  end

  def self.messages_this_month
    messages = Message.group_by_day(:created_at, range: 1.month.ago..Time.now).count
  end


  private

 
  def validate_attachment_filetypes
    return unless attachments.attached?
  
    allowed_content_types = %w[image/jpeg image/png image/gif video/mp4 video/mpeg audio/x-wav audio/mpeg audio/webm video/quicktime]
    max_size = 10.megabytes
  
    attachments.each do |attachment|
      unless attachment.content_type.in?(allowed_content_types)
        errors.add(:attachments, "must be a MOV, JPEG, PNG, GIF, MP4, MP3, WEBM, OR WAV file")
      end
  
      if attachment.blob.byte_size > max_size
        errors.add(:attachments, "file size exceeds the maximum allowed (#{max_size / 1.megabyte} MB)")
      end
    end
  end
  
  def notify_recipients
    users_in_room = room.joined_users
    users_in_room.each do |user|
      next if user.eql?(self.user)
      notification = CommentNotifier.with(record: self.room, message: self)
      notification.deliver(user)
    end
  end

  def broadcast_to_home_page
    broadcast_prepend_later_to "public_messages",
      target: "public_messages",
      partial: "messages/message_preview",
      locals: { message: self }
    messages_count = Message.where(room: Room.public_rooms).count
    if messages_count >= 10
      message_to_remove = Message.where(room: Room.public_rooms).order(created_at: :desc).limit(10).last
      broadcast_remove_to 'public_messages', target: message_to_remove
    end
  end
end
