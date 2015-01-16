Rails.application.routes.draw do
    namespace :api do
        namespace :v0 do
            match 'datacheck', to: 'data_checkers#check_data', :via => [:get, :put, :post]
        end
    end 
end
