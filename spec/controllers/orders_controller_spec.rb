require "rails_helper"

RSpec.describe OrdersController do
  before(:all) do
    @user = User.create!(nickname: "Tester", email: "tester@domain.com")
  end

  context "Unauthorized request" do
    it "POST /orders responds HTTP 401" do
      list = @user.lists.create!(name: "Test")

      post :create, params: { order: { list_id: list.id, name: "Test", price: 10 }}

      expect(response).to have_http_status(401)
    end

    it "DELETE /lists/:list_id/orders/:id responds HTTP 401" do
      list = @user.lists.create!(name: "Test")
      order = @user.orders.create!(list_id: list.id, name: "Order", price: 10)

      delete :destroy, params: { list_id: list.id, id: order.id }

      expect(response).to have_http_status(401)
    end
  end

  context "Authorized request" do
    before do
      request.headers.merge!(@user.create_new_auth_token)
    end

    describe "POST /orders" do
      it "responds HTTP 404 when list doesn't exist" do
        post :create, params: { order: { list_id: 666, name: "Test", price: 10 }}

        expect(response). to have_http_status(404)
      end

      it "responds HTTP 403 when list is closed" do
        list = @user.lists.create!(name: "Test", state: 3)

        post :create, params: { order: { list_id: list.id, name: "Test", price: 10 }}

        expect(response).to have_http_status(403)
      end

      it "responds HTTP 400 when name is missing" do
        list = @user.lists.create!(name: "Test")

        post :create, params: { order: { list_id: list.id, price: 10 }}

        expect(response).to have_http_status(400)
      end

      it "responds HTTP 400 when list_id doesn't exist" do
        post :create, params: { order: { name: "Test", price: 10 }}

        expect(response).to have_http_status(400)
      end

      it "responds HTTP 400 when name is to short" do
        list = @user.lists.create!(name: "Test")

        post :create, params: { order: { list_id: list.id, name: "as", price: 10 }}

        expect(response).to have_http_status(400)
      end

      it "responds HTTP 400 when price is missing" do
        list = @user.lists.create!(name: "Test")

        post :create, params: { order: { list_id: list.id, name: "Test" }}

        expect(response).to have_http_status(400)
      end

      it "responds HTTP 400 when price is less than 0" do
        list = @user.lists.create!(name: "Test")

        post :create, params: { order: { list_id: list.id, name: "Test", price: -1 }}

        expect(response).to have_http_status(400)
      end

      it "responds HTTP 400 when price is greater than 9999.99" do
        list = @user.lists.create!(name: "Test")

        post :create, params: { order: { list_id: list.id, name: "Test", price: 10000 }}

        expect(response).to have_http_status(400)
      end

      it "responds HTTP 200 data is correct" do
        list = @user.lists.create!(name: "Test")
        count = Order.count
        correct_name = "Somecorrectdata"

        post :create, params: { order: { list_id: list.id, name: correct_name, price: 10 }}

        expect(response).to have_http_status(200)
        expect(Order.count-count).to eq(1)
        expect(Order.last.name).to eq(correct_name)
        expect(Order.last.price).to eq(10)
      end

      it "responds HTTP 200 when name is correct and price has more than two decimal places" do
        list = @user.lists.create!(name: "Test")
        count = Order.count
        correct_name = "Somecorrectdata"

        post :create, params: { order: { list_id: list.id, name: correct_name, price: 666.666 }}

        expect(response).to have_http_status(200)
        expect(Order.count-count).to eq(1)
        expect(Order.last.name).to eq(correct_name)
        expect(Order.last.price).to eq(666.67)
      end

      it "responds HTTP 403 when user already made an order" do
        list = @user.lists.create!(name: "Test")
        @user.orders.create!(list_id: list.id, name: "Test", price: 10)

        post :create, params: { order: { list_id: list.id, name: "Test", price: 10 }}

        expect(response).to have_http_status(403)
      end
    end

    describe "DELETE /lists/:list_id/orders/:id" do
      let(:state_in_progress){ 0 }
      let(:state_ordered){ 3 }

      it "responds HTTP 404 when list doesn't exist" do
        list = @user.lists.create!(name: "Test")
        order = @user.orders.create!(list_id: list.id, name: "Order", price: 10)

        delete :destroy, params: { list_id: 666,  id: order.id }

        expect(response).to have_http_status(404)
      end

      it "responds HTTP 404 when order doesn't exist" do
        list = @user.lists.create!(name: "Test")

        delete :destroy, params: { list_id: list.id, id: 666 }

        expect(response).to have_http_status(404)
      end

      it "responds HTTP 404 when list doesn't match order" do
        list = @user.lists.create!(name: "Test")
        order = @user.orders.create!(list_id: list.id, name: "Order", price: 10)
        list2 = @user.lists.create!(name: "Test2")

        delete :destroy, params: { list_id: list2.id,  id: order.id }

        expect(response).to have_http_status(404)
      end

      it "responds HTTP 403 when list is closed" do
        list = @user.lists.create!(name: "Test", state: state_ordered)
        order = @user.orders.create!(list_id: list.id, name: "Order", price: 10)

        delete :destroy, params: { list_id: list.id,  id: order.id }

        expect(response).to have_http_status(403)
      end

      it "responds HTTP 403 when order belonges to different user" do
        user = User.create!(name: "Test", email: "test@domain.com")
        list = user.lists.create!(name: "Test", state: state_in_progress)
        order = user.orders.create!(list_id: list.id, name: "Order", price: 10)

        delete :destroy, params: { list_id: list.id,  id: order.id }

        expect(response).to have_http_status(403)
      end

      it "responds HTTP 200 when deleted successfuly" do
        list = @user.lists.create!(name: "Test")
        order = @user.orders.create!(list_id: list.id, name: "Order", price: 10)

        delete :destroy, params: { list_id: list.id,  id: order.id }

        expect(response).to have_http_status(200)
        expect{ Order.find(order.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
