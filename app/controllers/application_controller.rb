class AuthenticationRequired < StandardError; end

class ApplicationController < ActionController::Base

  rescue_from AuthenticationRequired, with: :authentication_required

  def authentication_required
    render "application/authentication_required", status: 401
  end

  private
  def current_user
    @current_user ||= TelegramChat.find_by(token: session[:token]) if session[:token].present?
    raise AuthenticationRequired if @current_user.nil?
    @current_user.update_column(:seen_on_web_at, Time.now) if @current_user.seen_on_web_at.nil? || Time.now - @current_user.seen_on_web_at > 600
    return @current_user
  end
end
