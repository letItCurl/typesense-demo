namespace :typesense do
  desc "Reindex all cars to Typesense"
  task reindex_cars: :environment do
    puts "Reindexing #{Car.count} cars to Typesense..."
    Car.reindex
    puts "Done!"
  end

  desc "Clear and reindex all cars (destructive)"
  task reindex_cars!: :environment do
    puts "Clearing and reindexing #{Car.count} cars to Typesense..."
    Car.reindex!
    puts "Done!"
  end
end
