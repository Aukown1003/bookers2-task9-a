class ChatsController < ApplicationController
  before_action :following_check, only: [:show]

  def show
    @user = User.find(params[:id])
    rooms = current_user.user_rooms.pluck(:room_id) #current_userの持つroom_idを取得
    user_rooms = UserRoom.find_by(user_id: @user.id, room_id: rooms)
    if user_rooms.nil?
      chat_room = Room.new
      chat_room.save
      UserRoom.create(user_id: current_user.id, room_id: chat_room.id)
      UserRoom.create(user_id: @user.id, room_id: chat_room.id)
    else
      chat_room = user_rooms.room
    end
    @chats = chat_room.chats
    @chat = Chat.new(room_id: chat_room.id)
  end

  def create
    @chat = current_user.chats.new(chat_params)
    @chat.save!
    redirect_to request.referer
  end

  private

  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end

  def following_check
    user = User.find(params[:id])
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end
  end
end
