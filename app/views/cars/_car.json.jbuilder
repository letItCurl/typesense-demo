json.extract! car, :id, :make, :model, :year, :engine_fuel_type, :engine_hp, :engine_cylinders, :transmission_type, :driven_wheels, :number_of_doors, :market_category, :vehicle_size, :vehicle_style, :highway_mpg, :city_mpg, :popularity, :msrp, :created_at, :updated_at
json.url car_url(car, format: :json)
