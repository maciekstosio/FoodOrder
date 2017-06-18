class User < ActiveRecord::Base
  # Include default devise modules.
  devise :omniauthable, :trackable, :database_authenticatable
  include DeviseTokenAuth::Concerns::User

  has_many :lists, dependent: :destroy
  has_many :orders
end
