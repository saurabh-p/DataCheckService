module NodeDuplicacyRemovalHelper

	def self.for_reading_levels
		node_detail = {"node_label" => "ReadingLevel", "primary_node_property" => "type"}
		self.using_property node_detail
	end

	def self.for_concentrations
		node_detail = {"node_label" => "Concentration", "primary_node_property" => "name"}
		self.using_property node_detail
	end
	
	def self.for_sports
		node_detail = {"node_label" => "Sport", "primary_node_property" => "name"}
		self.using_property node_detail
	end

	def self.for_degrees
		node_detail = {"node_label" => "Degree", "primary_node_property" => "name"}
		self.using_property node_detail
	end

	def self.for_authors alphabets
		@path = {"node_label" => "Author", "relationship" => "Wrote", "neighbour_node_label" => "Book", "neighbour_node_primary_property" => "indexed_title", "primary_node_property" => "name", "indexed_name" => "indexed_main_author_name", "ID" => 0, "name" => 1, "threshold_limit" => 0, "property_array" => ["ID", "indexed_main_author_name", "name"]}
		@checking_for_authors = true
		self.check_duplicacy_alphabetically alphabets
	end

	def self.for_books 
		@path = {"node_label" => "Book", "relationship" => "Wrote", "neighbour_node_label" => "Author", "neighbour_node_primary_property" => "indexed_main_author_name", "primary_node_property" => "indexed_title", "indexed_name" => "indexed_title", "ID" => 0, "title" => 1, "isbn" => 2, "author_name" => 1,"threshold_limit" => 2, "property_array" => ["ID", "indexed_title", "title" "isbn", "author_name"]}
		@checking_for_books = true
		self.using_path
		
	end

	def self.show_duplicates_by_alphabets alphabets
		self.for_authors alphabets
	end

	def self.for_months
		node_detail = {"node_label" => "Month", "primary_node_property" => "month"}
		self.using_property node_detail
	end
	
	def self.for_days		
		node_detail = {"node_label" => "Day", "primary_node_property" => "day"}
		self.using_property node_detail
	end

	def self.for_categories
		node_detail = {"node_label" => "Category", "primary_node_property" => "name"}
		self.using_property node_detail
	end

	private

	def self.init_neo
		@neo = Neography::Rest.new
	end


	def self.get_duplicates_using_path 

		node_type = ["original_node", "duplicate_node"]
		
		label_of_node = @path["node_label"]
		relation = @path["relationship"]
		neighbour_node_label = @path["neighbour_node_label"]
		property = @path["primary_node_property"]	

		match_clause_node = " MATCH (original_node:"+ label_of_node +")-[:"+ relation +"]-(neighbour_node:" +neighbour_node_label +"),"
		match_clause_duplicate_node = " (neighbour_node:"+ neighbour_node_label +")-[:"+ relation +"]-(duplicate_node:"+ label_of_node +")" 
		where_clause = " WHERE original_node <> duplicate_node AND original_node."+ property +"= duplicate_node."+ property 
		return_clause = " RETURN ID(original_node), ID(duplicate_node) "

		clause = match_clause_node + match_clause_duplicate_node + where_clause + return_clause

		duplicate_node_pairs = Hash[node_type.zip(self.query_result clause)]

		duplicate_node_pairs
	end
		
	def self.handle_relationship(is_incoming=true)
		relationship_data_incoming.each do |relationship|

			@neighbour_node = relationship["ID"].to_s
			@relation_type = relationship["relation"].to_s
			
			if @neighbour_node != @duplicate_node
				if is_incoming  
					self.edit_incoming_relations
				else
					self.edit_outgoing_relations
				end
				self.delete_relation
			end
		end
	end

	def self.using_property node_detail
		already_removed = []
	    duplicate_node_pairs = self.find_duplicate_nodes_using_property node_detail

		duplicate_node_pairs.each do |duplicate_node_pair|
			
			@original_node = duplicate_node_pair["original_node"].to_s
			@duplicate_node = duplicate_node_pair["duplicate_node"].to_s

			duplicate_node_pair.sort!{|x,y| x.to_i <=> y.to_i}

			if not (already_removed.include?(@original_node)) or (already_removed.include?(@duplicate_node))

				self.resolve_all_connections
				already_removed << @duplicate_node
			end
		end
	end

	def self.using_path 
		duplicate_node_pairs = self.get_duplicates_using_path

		duplicate_node_pairs.each do |duplicate_node_pair|
			@original_node = duplicate_node_pair["original_node"].to_s
			@duplicate_node = duplicate_node_pair["duplicate_node"].to_s
			self.resolve_all_connections
		
		end
	end


	def self.resolve_all_connections
		
		id_and_relation = ["relation", "ID"]
		outgoing_ids_and_relations = Hash[id_and_relation.zip(self.get_outgoing_ids_and_relations[0])]
		incoming_ids_and_relations = Hash[id_and_relation.zip(self.get_incoming_ids_and_relations[0])]

		self.handle_relationship(incoming_ids_and_relations)

		is_incoming = false
		self.handle_relationship(outgoing_ids_and_relations, is_incoming)

		self.delete_duplicate_node
	end

	def self.find_duplicate_nodes_using_property node_detail

		node_type = ["original_node", "duplicate_node"]
		node_label = node_detail["node_label"].to_s
		primary_node_property = node_detail["primary_node_property"]
		match_clause ="MATCH (original_node:" + node_label + "), (duplicate_node:" + node_label + ")"		
		where_clause = " WHERE original_node." + primary_node_property + " = duplicate_node." + primary_node_property
		return_clause = " RETURN ID(original_node), ID(duplicate)"
		clause = match_clause + where_clause + return_clause
		duplicate_node_pair = Hash[node_type.zip(self.query_result clause)] 

		duplicate_node_pair
	end

	def self.delete_duplicate_node

		match_clause = "MATCH (duplicate_node)"
		where_clause = " WHERE ID(duplicate_node) = " + @duplicate_node  
		delete_clause = "DELETE duplicate_node"
		clause = match_clause + where_clause + delete_clause
		self.query_result clause
	end

	def self.delete_relation 

		match_clause = " MATCH (duplicate_node)-[relation]-(neighbour_node) "
		where_clause_duplicate_node = " WHERE ID(duplicate_node) = " + @duplicate_node
		where_clause_sender_or_receiver = " AND ID(neighbour_node) = " + @neighbour_node
		where_clause_relation = " AND TYPE(relation) = " + @relation_type  
		delete_clause = " DELETE relation "
		
		clause = match_clause + where_clause_duplicate_node + where_clause_sender_or_receiver + where_clause_relation + delete_clause
		self.query_result clause
	end 

	def self.edit_incoming_relations 

		match_clause = " MATCH (original_node), (duplicate_node) "
		where_clause_node = " WHERE ID(original_node) = " + @original_node
		where_clause_sender = " AND ID(neighbour_node) = " + @neighbour_node
		merge_clause = "MERGE (neighbour_node)-[:" + @relation_type +"]->(original_node)"
		
		clause = match_clause + where_clause_node + where_clause_sender + merge_clause
		
		self.query_result clause
	end

	def self.edit_outgoing_relations 

		match_clause = " MATCH (original_node), (duplicate_node) "
		where_clause_node = " WHERE ID(original_node) = " + @original_node
		where_clause_receiver = " AND ID(neighbour_node) = "+ @neighbour_node
		merge_clause = "MERGE (neighbour_node)<-[:" + @relation_type +"]-(original_node)"  
		
		clause = match_clause + where_clause_node + where_clause_receiver + merge_clause
		
		self.query_result clause
	end
	def self.get_incoming_ids_and_relations 

		match_node = " MATCH (duplicate_node)<-[relation]-(senders)"
		where_clause = " WHERE ID(duplicate_node) = " + @duplicate_node  
		return_clause = " RETURN type(relation), ID(senders)"
		clause = match_node + where_clause + return_clause
		
		relationship_data_incoming = self.query_result(clause)
		
		relationship_data_incoming
	end

	def self.get_outgoing_ids_and_relations 

		match_node = " MATCH (duplicate_node)-[relation]->(receivers)"
		where_clause = " WHERE ID(duplicate_node) = " + @duplicate_node 
		return_clause = " RETURN type(relation), ID(receivers)"
		clause = match_node + where_clause + return_clause

		relationship_data_outgoing = self.query_result clause

		relationship_data_outgoing
	end


	def self.get_node_details start_clause
		
		array_of_hashed_nodes = []

		return_clause = ""
		for property in @path["property_array"]
			if property == "ID"
				return_clause += " RETURN "+ property + "(original_node)" 
			else
				return_clause += ", original_node."+ property
			end
		end
		
		clause = start_clause + return_clause
		
		puts clause.white.on_black
		
		node_detail = self.query_result clause
		
		for node in node_detail
			array_of_hashed_nodes << Hash[@path["property_array"].zip(node)]
		end
		array_of_hashed_nodes
	end

	def self.get_information_of_node node_id

		match_clause = "MATCH (node)"
		where_clause = "WHERE ID(node) = " + node_id 
		
		clause = match_clause + where_clause 

		self.get_node_details clause
	end

	def self.check_for_substring_for_isbn isbn1, isbn2
		if isbn1 != isbn2
			if isbn1.length >= isbn2.length
				is_substring = isbn1.include? isbn2
			else
				is_substring = isbn2.include? isbn1
			end			
		else
			is_substring = true
		end
		is_substring
	end

	def self.check_for_shortened_names name1, name2
	
		words_name2 = name2.split(" ").map(&:downcase)
		words_name1 = name1.split(" ").map(&:downcase)
		has_same_initials = true
	
		if name1 != name2
			for word_index in 0..([words_name1.length,words_name2.length].min - 1)
				if word_index == 0
					if words_name1[word_index][2] != words_name2[word_index][2]
						has_same_initials = false
					end
				end
					
				if words_name1[word_index] == words_name2[word_index]
					has_same_word_in_name = true
				end

				if words_name1[word_index][1] != words_name2[word_index][1]
					has_same_initials = false
				end
			end

			if has_same_word_in_name and has_same_initials
				probably_shortened = true
			end
		end		
		probably_shortened
	end
	
	def self.find_duplicates_beginning_with letters_having_duplicacy

		duplicate_pair = [] 

		for letters in letters_having_duplicacy
			
			start_clause = "START original_node = node:node_auto_index('" + @path["indexed_name"] + ":" + letters + "*') "
			

			@detail_of_nodes = self.get_node_details start_clause
			
			
			grouped = @detail_of_nodes.group_by{|row| [row["indexed_main_author_name"]]}
			@detail_of_nodes = grouped.values.select { |a| a.size > 1 }.flatten

			for @current_node in @detail_of_nodes
				for @comparing_node in @detail_of_nodes

					is_similar_node_for_books = @checking_for_books && (@current_node["ID"] != @comparing_node["ID"]) && (@current_node["indexed_title"] == @comparing_node["indexed_title"] or self.check_for_substring_for_isbn(@current_node["isbn"], @comparing_node["isbn"]))

					is_similar_node_for_author = @checking_for_authors && (@current_node["ID"] != @comparing_node["ID"]) && (@current_node["indexed_main_author_name"] == @comparing_node["indexed_main_author_name"] or self.check_for_shortened_names(@current_node["name"], @comparing_node["name"] ) )

					if is_similar_node_for_author or is_similar_node_for_books
						duplicates = []
						if self.check_duplicates_using_path
							
							duplicates << @current_node["ID"]
							duplicates << @comparing_node["ID"]
							
							duplicate_pair << duplicates

							@detail_of_nodes -= [@comparing_node]
								
							puts "#{@current_node} #{@comparing_node} #{@detail_of_nodes.length} "
						end
					end
				end
				@detail_of_nodes -= [@current_node]
			end
		end
	end

	def self.check_duplicates_using_path 
		
		is_same = false

		label_of_node = @path["node_label"]
		relation = @path["relationship"]
		neighbour_node_label = @path["neighbour_node_label"]
		property = @path["primary_node_property"]	
		
		match_clause_node = " MATCH (original_node:"+ label_of_node +")-[:"+ relation +"]-(neighbour_node:" +neighbour_node_label +"),"
		match_clause_duplicate_node = " (duplicate_neighbour_node:"+ neighbour_node_label +")-[:"+ relation +"]-(duplicate_node:"+ label_of_node +")" 
		where_clause = " WHERE original_node <> duplicate_node AND original_node."+ property +"= duplicate_node."+ property 
		and_clause = " AND ID(original_node) = " + @current_node["ID"].to_s + " AND ID(duplicate_node) = " + @comparing_node["ID"].to_s + " AND neighbour_node." + @path["neighbour_node_primary_property"] + " = duplicate_neighbour_node." + @path["neighbour_node_primary_property"] 
		return_clause = " RETURN COUNT(neighbour_node)"

		clause = match_clause_node + match_clause_duplicate_node + where_clause + and_clause + return_clause
		
		same_neighbours = (self.query_result clause)[0][0]
		
		if same_neighbours > 0
			is_same = true
		end
		is_same
	end

	def self.query_result clause
		@neo ||= self.init_neo
			
		puts clause.white.on_black

		result = @neo.execute_query clause

		
		result["data"]
	end
	
	def self.check_duplicacy_alphabetically (alphabets = ["a", "b","c", "d", "e","f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p","q", "r", "s", "t", "u", "v", "w", "x", "y", "z",])
		concatenate_list = []
		all_alphabets = ["a", "b","c", "d", "e","f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p","q", "r", "s", "t", "u", "v", "w", "x", "y", "z",]
		for alphabet in alphabets
			for all_alphabet in all_alphabets
				concatenate_list << (alphabet + all_alphabet)
			end
		end
		
		letters_having_duplicacy = []
		
		for letters in concatenate_list
			
			indexed_node_clause = "START original_node = node:node_auto_index('" + @path["indexed_name"] + ":" + letters + "*') "
			return_clause = "RETURN COUNT(original_node."+ @path["indexed_name"] + "), COUNT(DISTINCT(original_node."+ @path["indexed_name"] +"))"
			
			clause = indexed_node_clause + return_clause 

			if self.verify_duplicate_node(clause)
				letters_having_duplicacy << letters
			end
		end
		
		self.find_duplicates_beginning_with letters_having_duplicacy
	
	end

	def self.verify_duplicate_node clause
		@neo ||= self.init_neo
		
		puts clause.blue.on_red
		node_details = @neo.execute_query clause

		node_count = node_details["data"][0][0]
		distinct_node_count = node_details["data"][0][1]
		
		puts node_count.to_s.green.on_yellow
		if node_count != distinct_node_count
			has_duplicate = true
		end
	
		duplicate_author_count = node_details["data"][0][0] - node_details["data"][0][1]
		puts duplicate_author_count.to_s.green
		has_duplicate
	end
end
