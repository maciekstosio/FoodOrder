require "rails_helper"

RSpec.describe ListsController do
  before(:all) do
    @user = User.create!(nickname: "Tester", email: "tester@domain.com")
  end

  context "Unauthorized request" do
    it "GET /lists responds HTTP 401" do
      get :index

      expect(response).to have_http_status(401)
    end

    it "DELETE /lists/:id respondes HTTP 401 to unauthorized" do
      list = @user.lists.create!(name: "Test")
      delete :destroy, params: { id: list.id }

      expect(response).to have_http_status(401)
    end

    it "PUT /lists/:id respondes HTTP 401 to unauthorized" do
      list = @user.lists.create!(name: "Test")
      put :update, params: { id: list.id, list: {  state: 2 } }

      expect(response).to have_http_status(401)
    end

    it "POST /lists respondes with HTTP 403 to unauthorized" do
      post :create, params: { list: { name: "Test" }}

      expect(response).to have_http_status(401)
    end
  end

  context "Authorized request" do
    before do
      request.headers.merge!(@user.create_new_auth_token)
    end

    describe "GET /lists" do
      it "responds HTTP 200 when data doesn't exists" do
        get :index

        expect(response).to have_http_status(200)
      end

      it "responds with HTTP 200 and content when data exist" do
        lists = List.order(id: :desc).all
        orders = Order.joins(:user).select('orders.*, users.name as username, users.nickname as usernickname, users.image as userimage').all

        get :index

        expect(response).to have_http_status(200)
        expect(response.body).to eq({lists: lists, orders: orders }.to_json)
      end
    end

    describe "DELETE /lists/:id" do
      it "respondes HTTP 200" do
        list = @user.lists.create!(name: "Test")

        delete :destroy, params: { id: list.id }

        expect(response).to have_http_status(200)
        expect{ List.find(list.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "respondes HTTP 403 to foreigner" do
        user = User.create!(name: "Test", email: "test@domain.com")
        list = user.lists.create!(name: "Test")

        delete :destroy, params: { id: list.id }

        expect(response).to have_http_status(403)
      end

      it "respondes HTTP 404 when list doesn't exist" do
        delete :destroy, params: { id: 666 }

        expect(response).to have_http_status(404)
      end
    end

    describe "PUT /lists/:id" do
      it "respondes HTTP 404 when list doesn't exist" do
        put :update, params: { id: 666, list: { state: 2 } }

        expect(response).to have_http_status(404)
      end

      it "respondes HTTP 403 to foreigner" do
        user = User.create(name: "Test", email: "test@domain.com")
        list = user.lists.create!(name: "Test")

        put :update, params: { id: list.id, list: { state: 2 } }

        expect(response).to have_http_status(403)
      end

      it "respondes HTTP 200 to owner with valid state" do
        list = @user.lists.create!(name: "Test")

        put :update, params: { id: list.id, list: {  state: 2 } }

        expect(response).to have_http_status(200)
        expect(List.find(list.id).state).to eq(2)
      end

      it "respondes HTTP 400 to owner with unvalid state" do
        list = @user.lists.create!(name: "Test")

        put :update, params: { id: list.id, list: {  state: 5 } }

        expect(response).to have_http_status(400)
      end
    end

    describe "POST /lists" do
      it "respondes with HTTP 400 when name is empty" do
        post :create, params: { list: { name: "" } }

        expect(response).to have_http_status(400)
      end

      it "respondes with HTTP 400 when name is too short" do
        post :create, params: { list: { name: "ab" } }

        expect(response).to have_http_status(400)
      end

      it "respondes with HTTP 200 when link empty" do
        correct_name = "somenamewithcorrectlength"
        count = List.count

        post :create, params: { list: { name: correct_name, link: "" } }

        expect(response).to have_http_status(200)
        expect(List.count-count).to eq(1)
        expect(List.last.name).to eq(correct_name)
      end

      it "respondes with HTTP 400 when link wrong" do
        post :create, params: { list: { name: "Test", link: "asd" } }

        expect(response).to have_http_status(400)
      end

      it "respondes with HTTP 200 when both name and link valid" do
        correct_name = "somenamewithcorrectlength"
        correct_link = "http://correctwebsiteurl.pl"
        count = List.count

        post :create, params: { list: { name: correct_name, link: correct_link } }

        expect(response).to have_http_status(200)
        expect(List.count-count).to eq(1)
        expect(List.last.name).to eq(correct_name)
        expect(List.last.link).to eq(correct_link)
      end
    end
  end
end
