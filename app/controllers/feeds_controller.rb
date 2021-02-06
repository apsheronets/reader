class FeedsController < ApplicationController
  def index
    per_page = 30
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
      extract(epoch from COALESCE(sheets.feed_item_custom_date, sheets.feed_item_created_at)) AS first_order_num,
      extract(epoch from sheets.feed_item_remote_created_at) AS second_order_num,
      feedjira_entry,
      feed_items.feedjira_class,
      feedjira_version
    }).limit(per_page + 1)
    if params[:before].present?
      first, second, id = params[:before].split('_')
      @feed_items = @feed_items.where(
        "(COALESCE(sheets.feed_item_custom_date, sheets.feed_item_created_at), sheets.feed_item_remote_created_at, sheets.feed_item_id) < (to_timestamp(?), to_timestamp(?), ?)",
        first.to_f, second.to_f, id.to_i
      )
    end
    @feed_items = @feed_items.to_a
    @next = @feed_items[per_page]
    @first = @feed_items.first
    @feed_items = @feed_items.first(per_page)
  end
end
