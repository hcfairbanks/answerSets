Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post    '/job_answer_sets',      to: 'jobs#job_answer_sets'
end
