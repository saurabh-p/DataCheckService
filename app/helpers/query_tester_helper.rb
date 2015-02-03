module QueryTesterHelper
	def self.test_it
		@neo = Neography::Rest.new
		clause = "START original_node = node:node_auto_index('indexed_title:a*') RETURN ID(original_node), original_node.title, original_node.author_name LIMIT 1"
		puts @neo.execute_query clause
	end

	def self.complete_node
		@neo = Neography::Rest.new
		clause = "MATCH (n:Book) RETURN n.title, n.author_name, n.url limit 1"
		puts @neo.execute_query clause
	end
end