Rails.application.routes.draw do
  root "pages#home"

  resources :bookings, only: [:create, :show], param: :confirmation_token do
    member do
      delete :cancel
    end
  end

  resources :ai_assessments, only: [:create]

  resource :checkout, only: [:create] do
    get :success
    get :cancel
  end

  resource :course_session, only: [:new, :create, :destroy], path: "entrar" do
    get :magic, path: "magic/:token"
  end

  namespace :stripe do
    post :webhook, to: "webhooks#webhook"
  end

  get "/curso", to: "courses#show", as: :course_dashboard
  get "/curso/:lesson_key", to: "courses#lesson", as: :course_lesson
  patch "/curso/:lesson_key/progresso", to: "courses#complete_lesson", as: :complete_course_lesson
  get "/curso/avaliacao/quiz", to: "quizzes#show", as: :course_quiz
  post "/curso/avaliacao/quiz", to: "quizzes#create"
  get "/curso/avaliacao/workflow", to: "course_submissions#new", as: :new_course_submission
  post "/curso/avaliacao/workflow", to: "course_submissions#create", as: :course_submissions
  get "/certificados/:code", to: "certificates#show", as: :certificate
  get "/certificados/:code.pdf", to: "certificates#show", defaults: { format: :pdf }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/fundos-europeus-ia-pmes/:apoio", to: "pages#funding_support", as: :funding_support
  get "/:page", to: "pages#show", as: :page
  get "/:page.html", to: "pages#show"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
