require "rails_helper"

RSpec.describe ListsController do
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

  describe "GET #index" do
    it "responds HTTP 401 to unauthorized user" do
      get :index

      expect(response).to have_http_status(401)
    end

    it "responds HTTP 200 to authorized user" do
      request.headers.merge!(@user.create_new_auth_token)
      get :index

      expect(response).to have_http_status(200)
    end

    it "responds with HTTP 200 posts and orders to authorized user" do
      #Get excepted data
      lists = List.order(id: :desc).all
      orders = Order.joins(:user).select('orders.*, users.name as username, users.nickname as usernickname, users.image as userimage').all

      request.headers.merge!(@user.create_new_auth_token)
      get :index

      expect(response).to have_http_status(200)
      expect(response.body).to eq({lists: lists, orders: orders }.to_json)
    end
  end

  describe "DELETE #destroy" do
    it "respondes HTTP 401 to unauthorized" do
      list = @user.lists.create!(name: "Test")
      delete :destroy, params: { id: list.id }

      expect(response).to have_http_status(401)
    end

    it "respondes HTTP 200 to authorized owner" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      delete :destroy, params: { id: list.id }

      expect(response).to have_http_status(200)
      expect{ List.find(list.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "respondes HTTP 403 to authorized foreigner" do
      user = User.create!(name: "Test", email: "test@domain.com")
      list = user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      delete :destroy, params: { id: list.id }

      expect(response).to have_http_status(403)
    end

    it "respondes HTTP 404 to authorized when list doesn't exist" do
      request.headers.merge!(@user.create_new_auth_token)
      delete :destroy, params: { id: 666 }

      expect(response).to have_http_status(404)
    end
  end

  describe "PUT #update" do
    it "respondes HTTP 401 to unauthorized" do
      list = @user.lists.create!(name: "Test")
      put :update, params: { id: list.id, list: {  state: 2 } }

      expect(response).to have_http_status(401)
    end

    it "respondes HTTP 404 to authorized when list doesn't exist" do
      request.headers.merge!(@user.create_new_auth_token)
      put :update, params: { id: 666, list: {  state: 2 } }

      expect(response).to have_http_status(404)
    end

    it "respondes HTTP 403 to authorized foreigner" do
      user = User.create(name: "Test", email: "test@domain.com")
      list = user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      put :update, params: { id: list.id, list: {  state: 2 } }

      expect(response).to have_http_status(403)    end

    it "respondes HTTP 200 to authorized owner with valid state" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      put :update, params: { id: list.id, list: {  state: 2 } }

      expect(response).to have_http_status(200)
      expect(List.find(list.id).state).to eq(2)
    end

    it "respondes HTTP 400 to authorized owner with unvalid state" do
      list = @user.lists.create!(name: "Test")

      request.headers.merge!(@user.create_new_auth_token)
      put :update, params: { id: list.id, list: {  state: 5 } }

      expect(response).to have_http_status(400)
    end
  end

  describe "POST #create" do
    it "respondes with HTTP 403 to unauthorized" do
      post :create

      expect(response).to have_http_status(401)
    end

    it "respondes with HTTP 400 to authorized with empty name" do
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { list: { name: "" } }

      expect(response).to have_http_status(400)
    end

    it "respondes with HTTP 400 to authorized with to short name" do
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { list: { name: "ab" } }

      expect(response).to have_http_status(400)
    end

    it "respondes with HTTP 200 to authorized with to empty link" do
      count = List.count
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { list: { name: "somenamewithcorrectlength", link: "" } }

      expect(response).to have_http_status(200)
      expect(List.count-count).to eq(1)
      expect(List.last.name).to eq("somenamewithcorrectlength")
    end

    it "respondes with HTTP 400 to authorized with to wrong link" do
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { list: { name: "abc", link: "asd" } }

      expect(response).to have_http_status(400)
    end

    it "respondes with HTTP 200 to authorized with to correct name and link" do
      count = List.count
      request.headers.merge!(@user.create_new_auth_token)
      post :create, params: { list: { name: "somenamewithcorrectlength", link: "http://google.pl" } }

      expect(response).to have_http_status(200)
      expect(List.count-count).to eq(1)
      expect(List.last.name).to eq("somenamewithcorrectlength")
    end
  end
end
