class CarsController < ApplicationController
  def index
    search_params = {
      per_page: 12,
      page: params[:page] || 1
    }

    # Enable Natural Language Search when query is present
    if params[:q].present?
      search_params[:nl_query] = true
      search_params[:nl_model_id] = "openai-model"
    end

    result = Car.search(params[:q], Car::SEARCH_FIELDS, search_params)
    @pagy, @cars = result

    # Get parsed NL query from raw response (only on first page with query)
    if params[:q].present? && !turbo_frame_request?
      @parsed_nl_query = result.raw_answer.dig("parsed_nl_query", "generated_params")
    end

    if turbo_frame_request?
      render partial: "page", locals: { pagy: @pagy, cars: @cars, q: params[:q] }
    end
  end
end
