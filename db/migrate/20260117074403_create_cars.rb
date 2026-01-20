class CreateCars < ActiveRecord::Migration[8.1]
  def change
    create_table :cars do |t|
      t.string :make
      t.string :model
      t.integer :year
      t.string :engine_fuel_type
      t.decimal :engine_hp
      t.integer :engine_cylinders
      t.string :transmission_type
      t.string :driven_wheels
      t.integer :number_of_doors
      t.jsonb :market_category, default: []
      t.string :vehicle_size
      t.string :vehicle_style
      t.integer :highway_mpg
      t.integer :city_mpg
      t.integer :popularity
      t.integer :msrp

      t.timestamps
    end
  end
end
