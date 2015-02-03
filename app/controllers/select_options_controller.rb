class SelectOptionsController < ApplicationController
	
	def get_response
	end

	def check_response
		# response = o
		# render text: params[:duplicate_book

		@response = Api::V0::DataChecker.get_demo
		debugger
		render json: @response
		# render text: params[:duplicate_author]
	end
end
