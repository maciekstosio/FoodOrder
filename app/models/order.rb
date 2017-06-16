class Order < ApplicationRecord
  belonges_to :list
  belonges_to :user
end
