class Car < ApplicationRecord
  include Typesense

  attribute :market_category, default: -> { [] }

  typesense enqueue: true do
    attributes :make, :model, :year, :engine_fuel_type, :engine_hp,
               :engine_cylinders, :transmission_type, :driven_wheels,
               :number_of_doors, :vehicle_size, :vehicle_style,
               :highway_mpg, :city_mpg, :popularity, :msrp

    attribute :market_category do
      market_category || []
    end

    predefined_fields [
      { "name" => "make", "type" => "string", "facet" => true },
      { "name" => "model", "type" => "string", "facet" => true },
      { "name" => "year", "type" => "int32", "facet" => true },
      { "name" => "vehicle_size", "type" => "string", "facet" => true },
      { "name" => "vehicle_style", "type" => "string", "facet" => true },
      { "name" => "msrp", "type" => "int32" },
      { "name" => "popularity", "type" => "int32" }
    ]

    default_sorting_field "popularity"
  end
end

# == Schema Information
#
# Table name: cars
#
#  id                :bigint           not null, primary key
#  city_mpg          :integer
#  driven_wheels     :string
#  engine_cylinders  :integer
#  engine_fuel_type  :string
#  engine_hp         :decimal(, )
#  highway_mpg       :integer
#  make              :string
#  market_category   :jsonb
#  model             :string
#  msrp              :integer
#  number_of_doors   :integer
#  popularity        :integer
#  transmission_type :string
#  vehicle_size      :string
#  vehicle_style     :string
#  year              :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
