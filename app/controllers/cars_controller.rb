class CarsController < ApplicationController
  def index
    @pagy, @cars = Car.search(params[:q], "make,model,vehicle_style", {
      per_page: 12,
      page: params[:page] || 1
    })

    if turbo_frame_request?
      render partial: "page", locals: { pagy: @pagy, cars: @cars, q: params[:q] }
    end
  end
end
