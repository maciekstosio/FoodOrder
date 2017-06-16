class List < ApplicationRecord
  belongs_to :user
  has_many :orders

  validates :name, presence: true, length: {minimum: 3}
  validates :link, url: true
end
