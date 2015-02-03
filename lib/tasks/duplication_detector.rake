namespace :duplicate  do
	task :remove_duplicate_authors => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_authors
	end

	task :remove_duplicate_books => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_books
	end

	task :remove_duplicate_days => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_days
	end

	task :remove_duplicate_months => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_months
	end

	task :remove_duplicate_categories => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_categories
	end

	task :remove_duplicate_reading_levels => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_reading_levels
	end
	
	task :remove_duplicate_concentrations => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_concentrations
	end
	
	task :remove_duplicate_sports => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_sports
	end

	task :remove_duplicate_degrees => :environment do 
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.for_degrees
	end

	task :query_testing => :environment do
		include QueryTesterHelper
		QueryTesterHelper.test_it
	end

	task :query_testing_complete => :environment do
		include QueryTesterHelper
		QueryTesterHelper.complete_node
	end

	task :show_duplicates, [:alphabets] => :environment do  |task, args|
		include NodeDuplicacyRemovalHelper
		NodeDuplicacyRemovalHelper.show_duplicates_by_alphabets args.alphabets.split(//) 
	end
end
