Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "solve#top"
  post "solve/top"
  post "/" => "solve#top"
  get "/howto" => "solve#howto"
  get "/about" => "solve#about"
end
