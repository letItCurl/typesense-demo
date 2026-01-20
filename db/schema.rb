# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_17_074403) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cars", force: :cascade do |t|
    t.integer "city_mpg"
    t.datetime "created_at", null: false
    t.string "driven_wheels"
    t.integer "engine_cylinders"
    t.string "engine_fuel_type"
    t.decimal "engine_hp"
    t.integer "highway_mpg"
    t.string "make"
    t.jsonb "market_category", default: []
    t.string "model"
    t.integer "msrp"
    t.integer "number_of_doors"
    t.integer "popularity"
    t.string "transmission_type"
    t.datetime "updated_at", null: false
    t.string "vehicle_size"
    t.string "vehicle_style"
    t.integer "year"
  end
end
