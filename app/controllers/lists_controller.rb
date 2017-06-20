class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    lists = List.order(id: :desc).all
    orders = Order.joins(:user).select('orders.*, users.name as username, users.nickname as usernickname, users.image as userimage').all
    long_resp({ lists: lists, orders: orders} , 200)
  end

  def create
    list = current_user.lists.build(list_params)
    if list.save
      long_resp({ messages: ["List created successfuly"], id: list.id }, 200)
    else
      long_resp({ messages: list.errors.full_messages }, 400)
    end
  end

  def update
    list = List.where(id: params[:id])

    if list.blank?
      resp "List doesn't exit", 404
      return
    end

    if list.first.user_id!=current_user.id
      resp "You don't have permission to change status of this list", 403
      return
    end

    update_list = list.first

    if update_list.update_attributes(state_params)
      resp "State changed successfuly", 200
    else
      long_resp({ messages: update_list.errors.full_messages }, 400)
    end
  end

  def destroy
    list = List.where(id: params[:id])

    if list.blank?
      resp "List doesn't exist", 404
      return
    end

    if list.first.user_id!=current_user.id
      resp "You don't have permission to change state of this list", 403
      return
    end

    if list.first.destroy
      resp "List deleted successfuly", 200
    else
      long_resp({ messages: errors.full_messages }, status: 400)
    end
  end

  private

  def list_params
    params.require(:list).permit(:name,:link)
  end

  def state_params
    params.require(:list).permit(:state)
  end

  def resp(text,code)
    render json: {
      messages: [text]
    }, status: code
  end

  def long_resp(hash,code)
    render json: hash, status: code
  end
end
