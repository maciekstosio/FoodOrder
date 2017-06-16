class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: List.all, status: 200
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

  def show
  end

  def update
  end

  def destroy
  end

  private

  def list_params
    params.require(:list).permit(:name,:link)
  end
end
