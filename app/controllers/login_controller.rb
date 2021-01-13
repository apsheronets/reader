class LoginController < ApplicationController
  def login
    session[:token] = params[:token]
    redirect_to controller: :feeds, action: :index
  end
end
