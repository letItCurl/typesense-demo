class Car < ApplicationRecord
  # Just ensure we always have an array, not nil
  attribute :market_category, default: -> { [] }
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
