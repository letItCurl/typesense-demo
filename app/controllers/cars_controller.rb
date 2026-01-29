class CarsController < ApplicationController
  def index
    # Render shell with lazy-loading frame - search happens via turbo frame
  end

  def search
    searcher = Car::Searcher.new(search_params)
    @pagy, @cars = searcher.results

    locals = { pagy: @pagy, cars: @cars, q: params[:q], nl_params: searcher.nl_params }

    if params[:page].to_i > 1
      render partial: "page", locals: locals
    else
      render partial: "results", locals: locals.merge(parsed_nl_query: searcher.parsed_nl_query)
    end
  end

  private

  def search_params
    params.permit(:q, :page, :nl_filter_by, :nl_sort_by, :nl_q)
  end
end
