class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    order = current_user.orders.build(order_params)
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
  end

  def destroy
  end

  private

  def order_params
    params.require(:order).permit(:name,:price,:list_id);
  end
end
