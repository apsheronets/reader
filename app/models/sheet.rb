class Sheet < ApplicationRecord
  belongs_to :feed_item
  belongs_to :telegram_subscription
  belongs_to :telegram_chat
end
