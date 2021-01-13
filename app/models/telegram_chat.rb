class TelegramChat < ApplicationRecord
  has_many :sheets
  has_many :telegram_subscription
end
