module Api 
	module V0
		class DataCheckersController < ApplicationController 

			def check_data 
				# book_information = params[:info]
				book_information = nil
				response = DataChecker.check_the_data book_information
				render json: @response 
			end
		
		end
	end
end
