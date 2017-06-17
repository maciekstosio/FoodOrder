class List < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :destroy

  validates :name, presence: true, length: {minimum: 3}
  validates :link, url: true
  validates :state, inclusion: { in: [0,1,2,3] }
end
