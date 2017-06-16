class User < ActiveRecord::Base
  # Include default devise modules.
  devise :omniauthable, :database_authenticatable
  include DeviseTokenAuth::Concerns::User
end
