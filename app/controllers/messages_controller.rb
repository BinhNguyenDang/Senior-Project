class MessagesController < ApplicationController
    include MessagesHelper
    include MessageParser
  
    before_action :set_message, only: [:destroy, :edit, :update]
    before_action :set_commands
    def create
      # Create a new message associated with the current user
      @message = Message.new(
      body: msg_params[:body],
      room_id: params[:room_id],
      attachments: msg_params[:attachments],
      user_id: current_user.id
      )

      @message.body = parse_at_mentions(@message)

      parse_slash_commands(@message)
  

      unless @message.save
        render turbo_stream:
          turbo_stream.update('flash', partial: "shared/message_error", locals: {message: @message.errors.full_messages.join(", ")})
      end
    end

  

    def destroy
      @room = Room.find(params[:room_id])
      @message = @room.messages.find(params[:id])
      @message.destroy
      flash[:notice] = "Message deleted "
      redirect_to @room
    end

    def edit
    end

    def update
      if params[:message][:remove_attachments].present?
        params[:message][:remove_attachments].each do |attachment_id|
          attachment = @message.attachments.find(attachment_id)
          attachment.purge # or attachment.purge_later for background removal
        end
      end
    
      # Update message body or any other non-attachment attribute
      @message.update(body: msg_params[:body])
    
      # Add new attachments without removing existing ones
      if msg_params[:attachments]
        msg_params[:attachments].each do |new_attachment|
          @message.attachments.attach(new_attachment)
        end
      end
      
      flash[:notice] = "Message edited "
      redirect_to @room, notice: 'Message was successfully updated.'

    end
    
    
    private
    # Strong parameters method to ensure only permitted attributes are allowed
    def msg_params
      params.require(:message).permit(:body, attachments: [], remove_attachments: [])
    end

    def set_message
      @room = Room.find(params[:room_id])
      @message = @room.messages.find(params[:id])
    end
  end
  
