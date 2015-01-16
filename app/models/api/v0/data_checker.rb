require 'neography'
module Api
	module V0
		class DataChecker 
			
			def self.find_duplicate_author neo_instance
				duplicacy = neo_instance.execute_query("MATCH (a:Author)-[:Wrote]->(n:Book)<-[:Wrote]-(b:Author) where a<>b return a,b,n limit 25")
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
					neo_instance = configure_neography 
					# returned_data = neo_instance.execute_query("MATCH (n:Book) RETURN n LIMIT 25")
					returned_data = find_duplicate_author neo_instance
				rescue Exception => e
					returned_data = e.to_s
				end
				returned_data
			end

			def self.configure_neography
				begin 
					neo_instance = Neography::Rest.new({ :protocol => 'http://',
							                             :server         => 'localhost',
							                             :port           => 8000,
							                             :directory      => '',
							                             :authentication => 'basic',
							                             :username       => nil,
							                             :password       => nil,
							                             :log_file       => 'neography.log',
							                             :log_enabled    => false,
							                             :max_threads    => 20,
							                             :cypher_path    => '/cypher',
							                             :gremlin_path   => '/ext/GremlinPlugin/graphdb/execute_script' })
				rescue Exception => e
					neo_instance = e.to_s
				end
				neo_instance
			end

		end
	end
end
	
