require 'neography'
module Api
	module V0
		class DataChecker < ActiveRecord::Base
			
			def self.get_the_radio_response
				
			end

			def self.find_duplicate_author neo_instance
				neo_instance||= Neography::Rest.new
				duplicacy = neo_instance.execute_query("MATCH (a:Author)-[:Wrote]->(n:Book)<-[:Wrote]-(b:Author) 
														where a<>b 
														return a.name,b.name,n.title 
														limit 25")
				duplicacy
			end	

			def self.check_the_data book_information=nil
				begin 
					returned_data = get_demo
				rescue Exception => e
					returned_data = e.to_s
				end
				returned_data
			end	

			def self.get_demo neo_instance=nil
				begin 
					neo_instance = Neography::Rest.new
					returned_data = find_duplicate_author neo_instance
				rescue Exception => e
					returned_data = e.to_s
				end
				returned_data
			end

		end
	end
end
	
