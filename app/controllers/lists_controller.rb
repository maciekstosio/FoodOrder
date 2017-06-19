class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    lists = List.order(id: :desc).all
    orders = Order.joins(:user).select('orders.*, users.name as username, users.nickname as usernickname, users.image as userimage').all
    render json: { lists: lists, orders: orders} , status: 200
  end

  def create
    list = current_user.lists.build(list_params)
    if list.save
      render json: {
        messages: ["List created successfuly"],
        id: list.id
      }, status: 200
    else
      render json: {
        messages: list.errors.full_messages
      }, status: 400
    end
  end

  def update
    list = List.where(id: params[:id])
    if list.present?
      if list.first.user_id==current_user.id
        if list.first.update_attributes(state_params)
          render json: {
            messages: ["State changed successfuly"]
          }, status: 200
        else
          render json: {
            messages: errors.full_messages
          }, status: 400
        end
      else
        render json: {
          messages: ["You don't have permission to change status of this list"]
        }, status: 403
      end
    else
      render json: {
        messages: ["List doesn't exist"]
      }, status: 404
    end
  end

  def destroy
    list = List.where(id: params[:id])
    if list.present?
      if list.first.user_id==current_user.id
        if list.first.destroy
          render json: {
            messages: ["List deleted successfuly"]
          }, status: 200
        else
          render json: {
            messages: errors.full_messages
          }, status: 400
        end
      else
        render json: {
          messages: ["You don't have permission to change status of this list"]
        }, status: 403
      end
    else
      render json: {
        messages: ["List doesn't exist"]
      }, status: 404
    end
  end

  private

  def list_params
    params.require(:list).permit(:name,:link)
  end

  def state_params
    params.require(:list).permit(:state)
  end
end
