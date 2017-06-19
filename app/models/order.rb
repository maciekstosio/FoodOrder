class Order < ApplicationRecord
  belongs_to :list
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3 }
  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 10000 }
end
