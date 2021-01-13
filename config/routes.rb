Rails.application.routes.draw do
  root to: "feeds#index"
  get "/l/:token", to: "login#login"
end
