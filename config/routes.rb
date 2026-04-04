Rails.application.routes.draw do
  root "mushrooms#index"

  resources :mushrooms, only: [:index] do
    collection do
      post :score
      get :check_terrain
    end
  end
end
