module RelationAnomalyRemovalHelper

	def self.for_relations
		relation = {"type" => "Published_in"}
		remove_anomaly relation
	end

	private

	def self.remove_anomaly relation
		@relation_type = relation["type"].to_s
		anomalous_relation_id = get_anomalous_relation
	end

	def get_anomalous_relation
		@neo||= self.init_neo
		match_clause_left = "MATCH (left_node)-[relation_original:" + relation_type + "]-(connector_node),"
		match_clause_right = " (connector_node)-[anomalous_relation:" + relation_type + "]-(right_node)"
		where_clause = " WHERE LABELS(left_node) = LABELS(right_node) AND left_node<>right_node"
		return_clause = " RETURN ID(anomalous_relation)"
		clause = match_clause_left + match_clause_right + where_clause + return_clause
		anomalous_relation_id = @neo.execute_query clause
	end 

	def self.init_neo
		@neo = Neography::Rest.New
	end

end