class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # Define a scope to fetch all users except the current user
  scope :all_except, ->(user) { where.not(id: user)}
  
  # Define an Active Storage attachment for user avatars
  has_one_attached :avatar

  # Define a callback to add a default avatar (if none is attached) after a user is created or updated
  # When a new user is created (create event) or an existing user is updated (update event), the add_default_avatar method will be invoked.
  after_commit :add_default_avatar, on: %i[create update]
  # Define a callback to broadcast a message after a user is created
  # Show new user tab bar once a users is sign up in real time
  # append to "users" in div with users id in the index.html.erb
  after_create_commit { broadcast_append_to "users" }

  # Define a callback to broadcast a status update after a user's status is updated
  # This callback broadcasts a status update after a user's status is updated, used for real-time status updates.
  after_update_commit :broadcast_status_update, if: :saved_change_to_status?
  # Define association: a user has many messages
  has_many :messages

  # Define association: a user has many joinables
  has_many :joinables, dependent: :destroy
  
  # Define enumeration for user roles: user, admin
  has_many :joined_rooms, through: :joinables, source: :room

  validates_uniqueness_of :username,
                          required:true,
                          case_sensitive: false
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"

  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

   # Define enumeration for user roles: user, admin
  enum role: %i[user admin]
 
  # Define an enumeration for user status with three possible values: offline, away, and online
  # Rails creates a method called statuses on the User model, which returns a hash-like object. This object maps each enum value (e.g., :offline, :away, :online) to its corresponding integer value.
  enum status: %i[offline away online dnd]

  # This line sets up a callback to ensure that whenever a new instance of the User model is initialized,
  # the set_default_role method is called to assign a default role to the user if one is not already assigned.
  after_initialize :set_default_role, if: :new_record?
  
  # Generates a resized thumbnail of the user's avatar
  def avatar_thumbnail
    avatar.variant(resize_to_limit: [150,150]).processed
  end
   # Generates a resized avatar for use in chat
  def chat_avatar
    avatar.variant(resize_to_limit: [50,50]).processed
  end

  # Broadcasts an update to the user's status/ realtime update to users/status partial
  def broadcast_status_update
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_status:#{self.id}",
      target: "user_status_#{self.id}",
      partial: "users/status",
      locals: { user: self }
    )
  end

  # Checks if the user has joined a specific room
  def has_joined_room(room)
    joined_rooms.include?(room)
  end

   # Maps user status to corresponding CSS class for styling
  def status_to_css
    case status
    when 'online'
      'bg-success'
    when 'away'
      'bg-warning'
    when 'offline'
      'bg-dark'
    when 'dnd'
      'bg-danger'
    end
  end

  private
   # Adds a default avatar if none is attached
  def add_default_avatar
    return if avatar.attached?

      avatar.attach(
        io:File.open(Rails.root.join('app', 'assets', 'images', 'default_profile.jpg')),
        filename: 'default_profile.jpg',
        content_type: 'image/jpg'
      )
  end
   # Sets a default role for a new user
  def set_default_role
    self.role ||= :user
  end
end

