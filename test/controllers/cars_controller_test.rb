require "test_helper"

class CarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bmw = cars(:bmw_m3)
    @honda = cars(:honda_civic)
  end

  test "index renders successfully" do
    get cars_url
    assert_response :success
  end

  test "index shows search form" do
    get cars_url
    assert_select "form[action=?]", cars_path
    assert_select "input[name=q]"
  end

  test "index shows skeleton loading state" do
    get cars_url
    assert_select ".animate-pulse"
    assert_match /Loading results/, response.body
  end

  test "index has lazy-loading turbo frame pointing to search" do
    get cars_url
    assert_select "turbo-frame#search_results[loading=lazy]"
    assert_select "turbo-frame#search_results[src*='search']"
  end

  test "index shows search query when q param present" do
    get cars_url, params: { q: "BMW with 300hp" }
    assert_match /Searching for:.*BMW with 300hp/, response.body
  end

  test "search without query returns all cars" do
    with_mocked_search([@bmw, @honda], found: 2) do
      get search_cars_url
      assert_response :success
      assert_select "turbo-frame#search_results"
    end
  end

  test "search with q param performs NL search" do
    with_mocked_search([@bmw], found: 1, parsed_nl_query: {
      "generated_params" => {
        "filter_by" => "make:=BMW && engine_hp:>=300",
        "sort_by" => "engine_hp:desc",
        "q" => "*"
      }
    }) do
      get search_cars_url, params: { q: "BMW with at least 300hp" }
      assert_response :success
      assert_match /filter_by:/, response.body
    end
  end

  test "search with nl_params reuses cached params and skips NL search" do
    with_mocked_search([@bmw], found: 1) do
      get search_cars_url, params: {
        q: "BMW with at least 300hp",
        nl_filter_by: "make:=BMW && engine_hp:>=300",
        nl_sort_by: "engine_hp:desc",
        nl_q: "*"
      }
      assert_response :success
    end
  end

  test "search page 1 renders results partial with turbo frame" do
    with_mocked_search([@bmw, @honda], found: 2) do
      get search_cars_url
      assert_response :success
      assert_select "turbo-frame#search_results"
      assert_match /Found.*2.*results/, response.body
    end
  end

  test "search page > 1 renders page partial" do
    with_mocked_search([@bmw], found: 15, page: 2, has_next: true) do
      get search_cars_url, params: { page: 2 }
      assert_response :success
      assert_select "turbo-frame#cars_page_2"
    end
  end

  test "search returns turbo frame response without layout" do
    with_mocked_search([@bmw, @honda], found: 2) do
      get search_cars_url, headers: { "Turbo-Frame" => "search_results" }
      assert_response :success
      assert_no_match /<html/, response.body
    end
  end

  test "search shows empty state when no cars found" do
    with_mocked_search([], found: 0) do
      get search_cars_url, params: { q: "nonexistent car" }
      assert_response :success
      assert_match /No cars found/, response.body
    end
  end

  test "search pagination includes nl_params in next page link" do
    with_mocked_search([@bmw], found: 20, has_next: true, parsed_nl_query: {
      "generated_params" => {
        "filter_by" => "make:=BMW",
        "sort_by" => nil,
        "q" => "*"
      }
    }) do
      get search_cars_url, params: { q: "BMW" }
      assert_response :success
      assert_select "turbo-frame[src*='nl_filter_by']"
    end
  end

  private

  def with_mocked_search(cars, found:, page: 1, has_next: false, parsed_nl_query: nil)
    pagy = MockPagy.new(count: found, page: page, next_page: has_next ? page + 1 : nil)

    raw_answer = {
      "found" => found,
      "hits" => cars.map { |c| { "document" => { "id" => c.id.to_s } } },
      "parsed_nl_query" => parsed_nl_query
    }

    result = [pagy, cars]
    result.define_singleton_method(:raw_answer) { raw_answer }

    original_search = Car.method(:search)
    Car.define_singleton_method(:search) { |*_args| result }

    yield
  ensure
    Car.define_singleton_method(:search, original_search)
  end

  class MockPagy
    attr_reader :count, :page

    def initialize(count:, page:, next_page:)
      @count = count
      @page = page
      @next_page = next_page
    end

    def next
      @next_page
    end
  end
end
