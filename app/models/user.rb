class User < ActiveRecord::Base
  has_many :lists
  has_many :orders
  # Include default devise modules.
  devise :omniauthable, :database_authenticatable
  include DeviseTokenAuth::Concerns::User
end
