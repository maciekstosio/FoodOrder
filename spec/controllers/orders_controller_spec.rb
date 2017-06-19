require "rails_helper"

RSpec.describe OrdersController do
  before(:all) do
    # Add users
    @user = User.create!(nickname: "Tester", email: "tester@domain.com")
    user = User.create!(nickname: "User", email: "user@domain.com")
    user2 = User.create!(nickname: "User2", email: "user2@domain.com")

    # Add lists
    list = user.lists.create!(name: "List1")
    list2 = user2.lists.create!(name: "List2")

    #Add orders
    order = list.orders.create!(name: "Order", price: 10, user_id: user.id)
  end

  describe "POST #create" do
    it "responds HTTP 401 to unauthorized user" do
      post :create, params: { order: { name: "Test", price: 10 }}

      expect(response).to have_http_status(401)
    end

    it "responds HTTP 404 to authorized user when list doesn't exist" do
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: 666, name: "Test", price: 10 }}

      expect(response). to have_http_status(404)
    end

    it "responds HTTP 403 to authorized user when list is closed" do
      list = @user.lists.create!(name: "Test", state: 3)

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, name: "Test", price: 10 }}

      expect(response).to have_http_status(403)
    end

    it "responds HTTP 400 to authorized user when name doesn't exist" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, price: 10 }}

      expect(response).to have_http_status(400)
    end

    it "responds HTTP 400 to authorized user when list_iddoesn't exist" do
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { name: "Test", price: 10000 }}

      expect(response).to have_http_status(400)
    end

    it "responds HTTP 400 to authorized user when name is to short" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, name: "as", price: 10 }}

      expect(response).to have_http_status(400)
    end

    it "responds HTTP 400 to authorized user when price doesn't exist" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, name: "Test" }}

      expect(response).to have_http_status(400)
    end

    it "responds HTTP 400 to authorized user when price is less than 0" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, name: "Test", price: -1 }}

      expect(response).to have_http_status(400)
    end

    it "responds HTTP 400 to authorized user when price is greater than 9999.99" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, name: "Test", price: 10000 }}

      expect(response).to have_http_status(400)
    end

    it "responds HTTP 200 to authorized user data is correct" do
      list = @user.lists.create!(name: "Test")
      count = Order.count

      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { order: { list_id: list.id, name: "Somecorrectdata", price: 666 }}

      expect(response).to have_http_status(200)
      expect(Order.count-count).to eq(1)
      expect(Order.last.name).to eq("Somecorrectdata")
      expect(Order.last.price).to eq(666)
    end
    #Precision test
  end
end
