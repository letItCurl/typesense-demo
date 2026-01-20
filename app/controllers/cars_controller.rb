class CarsController < ApplicationController
  def index
    search_params = {
      per_page: 12,
      page: params[:page] || 1
    }

    # Check if we have cached NL params from a previous search
    if params[:nl_filter_by].present? || params[:nl_sort_by].present? || params[:nl_q].present?
      # Reuse parsed NL params for pagination (skip expensive NL search)
      search_params[:filter_by] = params[:nl_filter_by] if params[:nl_filter_by].present?
      search_params[:sort_by] = params[:nl_sort_by] if params[:nl_sort_by].present?
      query = params[:nl_q].presence || "*"

      result = Car.search(query, Car::SEARCH_FIELDS, search_params)
      @pagy, @cars = result
      @nl_params = { filter_by: params[:nl_filter_by], sort_by: params[:nl_sort_by], q: params[:nl_q] }
    elsif params[:q].present?
      # Initial NL search - let Typesense parse the natural language query
      search_params[:nl_query] = true
      search_params[:nl_model_id] = "openai-model"

      result = Car.search(params[:q], Car::SEARCH_FIELDS, search_params)
      @pagy, @cars = result

      # Extract parsed params for reuse in pagination
      @parsed_nl_query = result.raw_answer.dig("parsed_nl_query", "generated_params")
      @nl_params = {
        filter_by: @parsed_nl_query&.dig("filter_by"),
        sort_by: @parsed_nl_query&.dig("sort_by"),
        q: @parsed_nl_query&.dig("q")
      }
    else
      # No search query - just list all cars
      result = Car.search("*", Car::SEARCH_FIELDS, search_params)
      @pagy, @cars = result
    end

    if turbo_frame_request?
      render partial: "page", locals: { pagy: @pagy, cars: @cars, q: params[:q], nl_params: @nl_params }
    end
  end
end
