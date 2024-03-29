module RelationAnomalyRemovalHelper

	def self.for_published_in
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end


	def self.for_next_year
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_next_book
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_next_small_read
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	
	def self.next_normal_read
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_next_tiny_read
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_next_long_read
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_gave_feedback
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_data_edit_request
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_data_edit
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_labelled
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_ego
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	def self.for_next_grid
		@relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	private

	def self.remove_anomaly relation
		@relation_type = relation["type"].to_s
		anomalous_relation_id = get_anomalous_relation
	end

	def self.init_neo
		@neo = Neography::Rest.New
	end

	def get_anomalous_relation
		
		@neo||= self.init_neo
		match_clause_left = "MATCH (left_node)-[relation_original:" + relation_type + "]-(connector_node),"
		match_clause_right = " (connector_node)-[anomalous_relation:" + relation_type + "]-(right_node)"
		where_clause = " WHERE LABELS(left_node) = LABELS(right_node)" 
		return_clause = " RETURN ID(anomalous_relation)"
		clause = match_clause_left + match_clause_right + where_clause + return_clause
		
		anomalous_relation_id = execute_query clause

	end 

	def execute_query clause
		@neo = self.init_neo
		query_result = @neo.execute_query clause
		query_result["data"]
	end

end