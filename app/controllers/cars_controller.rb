class CarsController < ApplicationController
  def index
    @pagy, @cars = pagy(:offset, Car.all, limit: 12)

    if turbo_frame_request?
      render partial: "page", locals: { pagy: @pagy, cars: @cars }
    end
  end
end
