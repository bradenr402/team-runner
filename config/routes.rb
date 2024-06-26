Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             }

  resources :runs
  resources :users, only: %i[show]
  resources :teams
  post 'remove_member', to: 'teams#remove_member'

  post 'team_join_requests/:id/create',
       to: 'team_join_requests#create',
       as: 'create_request'
  delete 'team_join_requests/:id/cancel',
         to: 'team_join_requests#destroy',
         as: 'cancel_request'
  patch 'team_join_requests/:id/approve',
        to: 'team_join_requests#approve',
        as: 'approve_request'
  patch 'team_join_requests/:id/reject',
        to: 'team_join_requests#reject',
        as: 'reject_request'

  post 'teams/:id/join', to: 'teams#join', as: 'join_team'
  post 'teams/:id/leave', to: 'teams#leave', as: 'leave_team'

  root 'users#profile'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', :as => :rails_health_check
end
