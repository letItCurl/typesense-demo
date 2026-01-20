# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'json'
require 'ruby-progressbar'

cars_file = Rails.root.join('db/fixtures/cars.jsonl')
total_lines = File.foreach(cars_file).count

progressbar = ProgressBar.create(
  title: 'Seeding cars',
  total: total_lines,
  format: '%t: |%B| %c/%C %p%% %e'
)

File.foreach(cars_file) do |line|
  attributes = JSON.parse(line, symbolize_names: true)
  Car.find_or_create_by!(
    make: attributes[:make],
    model: attributes[:model],
    year: attributes[:year]
  ) do |car|
    car.assign_attributes(attributes)
  end
  progressbar.increment
end

puts "Seeded #{total_lines} cars."
