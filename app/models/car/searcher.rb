class Car::Searcher
  attr_reader :params, :nl_params, :parsed_nl_query

  def initialize(params)
    @params = params
  end

  def results
    @results ||= perform_search
  end

  private

  def perform_search
    if cached_nl_params?
      search_with_cached_params
    elsif params[:q].present?
      search_with_nl_query
    else
      search_all
    end
  end

  def cached_nl_params?
    params[:nl_filter_by].present? || params[:nl_sort_by].present? || params[:nl_q].present?
  end

  def search_with_cached_params
    @nl_params = {
      filter_by: params[:nl_filter_by],
      sort_by: params[:nl_sort_by],
      q: params[:nl_q]
    }

    Car.search(
      params[:nl_q].presence || "*",
      Car::SEARCH_FIELDS,
      base_search_params.merge(
        filter_by: params[:nl_filter_by],
        sort_by: params[:nl_sort_by]
      ).compact
    )
  end

  def search_with_nl_query
    result = Car.search(
      params[:q],
      Car::SEARCH_FIELDS,
      base_search_params.merge(nl_query: true, nl_model_id: "openai-model")
    )

    @parsed_nl_query = result.raw_answer.dig("parsed_nl_query", "generated_params")
    @nl_params = @parsed_nl_query&.slice("filter_by", "sort_by", "q")&.symbolize_keys

    result
  end

  def search_all
    Car.search("*", Car::SEARCH_FIELDS, base_search_params)
  end

  def base_search_params
    { per_page: 12, page: params[:page] || 1 }
  end
end
