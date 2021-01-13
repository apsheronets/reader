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
    return @current_user
  end
end
