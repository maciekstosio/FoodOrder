class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:order][:list_id].nil?
      resp "ID must be given", 400
      return
    end

    list = List.where(id: params[:order][:list_id])

    if list.blank?
      resp "List doesn't exist", 404
      return
    end

    if list.first.state!=0
      resp "This list is closed, you can't add new order", 403
      return
    end

    if current_user.orders.where(list_id: params[:order][:list_id]).count!=0
      resp "You can't order more than one think", 403
      return
    end

    order = current_user.orders.build(order_params)

    if order.save
      long_resp({ messages: ["Order added successfuly"], id: order.id }, 200)
    else
      long_resp({ messages: order.errors.full_messages }, 400)
    end
  end

  def destroy
    list = List.where(id: params[:list_id])

    if list.blank?
      resp "List doesn't exsist", 404
      return
    end

    order = Order.where(id: params[:id], list_id: params[:list_id])

    if order.blank?
      resp "Order doesn't exist", 404
      return
    end

    if order.first.user_id != current_user.id
      resp "You don't have permission to delete this order", 403
      return
    end

    if list.first.state!=0
      resp "This list is closed, you can't delete your order", 403
      return
    end

    if order.first.destroy
      resp "Order deleted successfuly", 200
    else
      long_resp({ messages: order.errors.full_messages }, 400)
    end
  end

  private

  def order_params
    params.require(:order).permit(:name,:price,:list_id);
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
