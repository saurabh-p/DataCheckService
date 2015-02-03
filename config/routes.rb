Rails.application.routes.draw do
# match 'datacheck', to: 'select_options#get_response', :via => [:get, :put, :post]
match 'check', to: 'select_options#get_response', :via => [:get, :put, :post]
match 'check_it', to: 'select_options#check_response', :via => [:get, :put, :post]
root :to => 'select_options#get_response'    
# namespace :api do
    #     namespace :v0 do
    #     end
    # end 
end
