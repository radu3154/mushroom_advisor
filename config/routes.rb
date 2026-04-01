Rails.application.routes.draw do
  root "mushrooms#index"

  resources :mushrooms, only: [:index] do
    collection do
      post :score
    end
  end
end
