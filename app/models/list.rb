class List < ApplicationRecord
  belonges_to :user
  has_many :orders
end
