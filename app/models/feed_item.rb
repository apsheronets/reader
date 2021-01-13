class FeedItem < ApplicationRecord
  has_many :sheets
  belongs_to :feed
end
