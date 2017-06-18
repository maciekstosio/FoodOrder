class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    order = current_user.orders.build(order_params)
    list = List.where(id: params[:list_id])
    if list.present?
      if list.first.state==0
        if current_user.orders.where(list_id: params[:list_id]).count==0
          if order.save
            render json: {
              messages: ["Order added successfuly"],
              id: order.id
            }, status: 200
          else
            render json: {
              messages: order.errors.full_messages
            }, status: 400
          end
        else
          render json: {
            messages: ["You can't order more than one thing"]
          }, status: 400
        end
      else
        render json: {
          messages: ["This list is closed for new orders"]
        }, status: 400
      end
    else
      render json: {
        messages: ["List doesn't exists"]
      }, status: 400
    end
  end

  def destroy
    list = List.where(id: params[:list_id])
    order = Order.where(id: params[:id], list_id: params[:list_id])
    if list.present?
      if order.present?
        if list.first.state==0
          if order.first.destroy
            render json: {
              messages: ["Order deleted successfuly"]
            }, status: 200
          else
            render json: {
              messages: order.errors.full_messages
            }, status: 400
          end
        else
          render json: {
            messages: ["This list is closed, you can't delete your order"]
          }, status: 400
        end
      else
        render json: {
          messages: ["Order doesn't exists"]
        }, status: 400
      end
    else
      render json: {
        messages: ["List doesn't exists"]
      }, status: 400
    end
  end

  private

  def order_params
    params.require(:order).permit(:name,:price,:list_id);
  end
end
