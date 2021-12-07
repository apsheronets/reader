class FeedItem < ApplicationRecord
  has_many :sheets
  belongs_to :feed

  # backward compatibility
  def itunes_enclosure_url
    super || self.feedjira_entry.try("[]", "enclosure_url")
  end

  def itunes_enclosure_type
    super || self.feedjira_entry.try("[]", "enclosure_type")
  end

  def youtube_video_id
    super || self.feedjira_entry.try("[]", "youtube_video_id")
  end

  def content
    super || self.feedjira_entry.try("[]", "content")
  end

  def summary
    super || self.feedjira_entry.try("[]", "summary")
  end
end
