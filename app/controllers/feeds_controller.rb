class FeedsController < ApplicationController
  def index
    per_page = 40
    @feed_items = FeedItem.where(
      sheets: { telegram_chat_id: current_user.id }
    ).where(
      # Since we have no foreign key sheet→telegram_subscription with ON DELETE CASCADE,
      # we have to filter all the sheets manually.
      "sheets.feed_id IN (SELECT feed_id FROM telegram_subscriptions WHERE telegram_chat_id = ?)", current_user.id
    ).joins(
      :sheets,
      :feed
    ).order(
      #"sheets.feed_item_created_at": :desc,
      #"sheets.feed_item_remote_created_at": :desc,
      #"sheets.feed_item_id": :desc

      # and this is how you do it in ActiveRecord 6!
      Arel.sql %{
      COALESCE(sheets.feed_item_custom_date, sheets.feed_item_created_at) DESC,
      sheets.feed_item_remote_created_at DESC,
      sheets.feed_item_id DESC }
    ).where(
      "feedjira_entry IS NOT NULL"
    ).select(%{
      feed_items.id,
      feed_items.feed_id,
      feed_items.title,
      feed_items.url,
      feeds.title AS feed_title,
      feeds.url AS feed_url,
      feed_items.created_at,
      remote_created_at,
      custom_date,
      feedjira_entry,
      feed_items.feedjira_class,
      feedjira_version
    }).limit(per_page + 1)
    if params[:before].present?
      created_at, remote_created_at, id = params[:before].split('_')
      created_at = Time.at(created_at.to_f)
      if remote_created_at.blank?
        remote_created_at = nil
      else
        remote_created_at = Time.at(remote_created_at.to_f)
      end
      id = id.to_i
      @feed_items = @feed_items.where(
        #"(sheets.feed_item_created_at, sheets.feed_item_remote_created_at, sheets.feed_item_id) < (?, ?, ?)",
        "(COALESCE(sheets.feed_item_custom_date, sheets.feed_item_created_at), sheets.feed_item_remote_created_at, sheets.feed_item_id) < (?, ?, ?)",
        created_at, remote_created_at, id)
    end
    @feed_items = @feed_items.to_a
    @next = @feed_items[per_page]
    @first = @feed_items.first
    @feed_items = @feed_items.first(per_page)
  end
end
