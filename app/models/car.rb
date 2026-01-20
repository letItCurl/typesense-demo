class Car < ApplicationRecord
  include Typesense

  attribute :market_category, default: -> { [] }

  # String fields for Typesense query_by (text search)
  SEARCH_FIELDS = %w[
    make model engine_fuel_type transmission_type
    driven_wheels vehicle_size vehicle_style market_category
  ].join(",").freeze

  typesense enqueue: true do
    attributes :make, :model, :year, :engine_fuel_type,
               :engine_cylinders, :transmission_type, :driven_wheels,
               :number_of_doors, :vehicle_size, :vehicle_style,
               :highway_mpg, :city_mpg, :popularity, :msrp

    # Convert BigDecimal to float for Typesense
    attribute :engine_hp do
      engine_hp&.to_f
    end

    attribute :market_category do
      market_category || []
    end

    predefined_fields [
      # String fields (searchable)
      { "name" => "make", "type" => "string", "facet" => true },
      { "name" => "model", "type" => "string", "facet" => true },
      { "name" => "engine_fuel_type", "type" => "string", "facet" => true },
      { "name" => "transmission_type", "type" => "string", "facet" => true },
      { "name" => "driven_wheels", "type" => "string", "facet" => true },
      { "name" => "vehicle_size", "type" => "string", "facet" => true },
      { "name" => "vehicle_style", "type" => "string", "facet" => true },
      # Numeric fields (for filtering/sorting)
      { "name" => "year", "type" => "int32", "facet" => true },
      { "name" => "engine_hp", "type" => "float" },
      { "name" => "engine_cylinders", "type" => "int32", "facet" => true },
      { "name" => "number_of_doors", "type" => "int32", "facet" => true },
      { "name" => "highway_mpg", "type" => "int32" },
      { "name" => "city_mpg", "type" => "int32" },
      { "name" => "msrp", "type" => "int32" },
      { "name" => "popularity", "type" => "int32" },
      # Array field
      { "name" => "market_category", "type" => "string[]", "facet" => true }
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
