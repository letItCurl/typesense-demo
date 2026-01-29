namespace :typesense do
  desc "Ping Typesense server and test NL Search support"
  task ping_nl: :environment do
    client = typesense_client

    puts "Checking Typesense health..."
    response = client.get("health")
    puts "Health: #{JSON.pretty_generate(response.body)}"

    puts "\nChecking Natural Language Search support..."
    response = client.get("nl_search_models")

    if response.status == 404
      puts "NL Search NOT supported (requires Typesense v29+)"
      puts "Current response: #{response.body}"
      next
    end

    puts "NL Search supported!"
    models = response.body
    puts "Models: #{JSON.pretty_generate(models)}"

    if models.empty?
      puts "\nNo NL models configured. Run: bin/rails typesense:create_nl_model"
      next
    end

    # Get collection name
    collection_name = Car.typesense_collection_name
    puts "\nPerforming NL Search test on '#{collection_name}'..."

    query = "BMW or Audi with at least 300hp, under 60K"
    puts "Query: \"#{query}\""

    # All string fields for query_by (numeric fields are used for NL filtering)
    search_fields = %w[
      make model engine_fuel_type transmission_type
      driven_wheels vehicle_size vehicle_style market_category
    ].join(",")

    response = client.get("collections/#{collection_name}/documents/search") do |req|
      req.params = {
        q: query,
        query_by: search_fields,
        nl_query: true,
        nl_model_id: "openai-model",
        per_page: 3
      }
    end

    if response.success?
      result = response.body
      puts "\nResults found: #{result['found']}"
      puts "Parse time: #{result.dig('parsed_nl_query', 'parse_time_ms')}ms"
      puts "Generated params: #{JSON.pretty_generate(result.dig('parsed_nl_query', 'generated_params'))}"

      puts "\nTop 3 results:"
      result["hits"].each_with_index do |hit, i|
        doc = hit["document"]
        puts "  #{i + 1}. #{doc['year']} #{doc['make']} #{doc['model']} - $#{doc['msrp']} (#{doc['engine_hp']}hp)"
      end
    else
      puts "Search failed: #{response.status}"
      puts response.body
    end

    puts "\nNL Search test complete!"
  rescue Faraday::ConnectionFailed => e
    puts "Connection failed: #{e.message}"
    puts "Make sure Typesense is running (bin/dev or docker compose up)"
  end

  desc "Check state of Typesense collection and documents"
  task status: :environment do
    client = typesense_client
    collection_name = Car.typesense_collection_name

    puts "=" * 60
    puts "TYPESENSE STATUS"
    puts "=" * 60

    # Check health
    puts "\n📡 Server Health"
    puts "-" * 40
    response = client.get("health")
    if response.success?
      puts "Status: #{response.body['ok'] ? '✅ Healthy' : '❌ Unhealthy'}"
    else
      puts "Status: ❌ Cannot connect (#{response.status})"
      next
    end

    # Check collection
    puts "\n📁 Collection: #{collection_name}"
    puts "-" * 40
    response = client.get("collections/#{collection_name}")

    if response.status == 404
      puts "Status: ❌ Collection not found"
      puts "Run: bin/rails typesense:reindex_cars! to create"
      next
    end

    collection = response.body
    puts "Status: ✅ Exists"
    puts "Created at: #{Time.at(collection['created_at']).strftime('%Y-%m-%d %H:%M:%S')}" if collection["created_at"]
    puts "Default sorting: #{collection['default_sorting_field']}"

    # Document counts
    puts "\n📊 Document Counts"
    puts "-" * 40
    typesense_count = collection["num_documents"]
    rails_count = Car.count
    puts "Typesense: #{typesense_count}"
    puts "Rails DB:  #{rails_count}"

    if typesense_count == rails_count
      puts "Sync: ✅ In sync"
    else
      diff = rails_count - typesense_count
      puts "Sync: ⚠️  Out of sync (#{diff > 0 ? '+' : ''}#{diff} in Rails)"
      puts "Run: bin/rails typesense:reindex_cars to sync"
    end

    # Schema/Fields
    puts "\n🔧 Schema Fields"
    puts "-" * 40
    collection["fields"].each do |field|
      facet = field["facet"] ? " [facet]" : ""
      optional = field["optional"] ? " (optional)" : ""
      puts "  #{field['name']}: #{field['type']}#{facet}#{optional}"
    end

    # Sample documents
    puts "\n📄 Sample Documents (5)"
    puts "-" * 40
    response = client.get("collections/#{collection_name}/documents/search") do |req|
      req.params = { q: "*", query_by: "make", per_page: 5 }
    end

    if response.success? && response.body["hits"].any?
      response.body["hits"].each_with_index do |hit, i|
        doc = hit["document"]
        puts "  #{i + 1}. [#{doc['id']}] #{doc['year']} #{doc['make']} #{doc['model']} - $#{doc['msrp']}"
      end
    else
      puts "  No documents found"
    end

    puts "\n" + "=" * 60
  rescue Faraday::ConnectionFailed => e
    puts "❌ Connection failed: #{e.message}"
    puts "Make sure Typesense is running (bin/dev or docker compose up)"
  end

  desc "Reindex all cars to Typesense"
  task reindex_cars: :environment do
    puts "Reindexing #{Car.count} cars to Typesense..."
    Car.reindex
    puts "Done!"
  end

  desc "Clear and reindex all cars (destructive)"
  task reindex_cars!: :environment do
    puts "Clearing and reindexing #{Car.count} cars to Typesense..."
    Car.reindex!
    puts "Done!"
  end

  desc "Create Natural Language Search model (OpenAI)"
  task create_nl_model: :environment do
    client = typesense_client

    response = client.post("nl_search_models") do |req|
      req.body = {
        id: "openai-model",
        model_name: "openai/gpt-4o",
        api_key: Rails.application.credentials.dig(:typesense, :openai_api_key),
        max_bytes: 16000,
        temperature: 0.0
      }
    end

    if response.success?
      puts "NL Search model created successfully!"
      puts JSON.pretty_generate(response.body)
    else
      puts "Error creating NL model: #{response.status}"
      puts response.body
    end
  end

  desc "List Natural Language Search models"
  task list_nl_models: :environment do
    client = typesense_client
    response = client.get("nl_search_models")
    puts JSON.pretty_generate(response.body)
  end

  desc "Delete Natural Language Search model"
  task :delete_nl_model, [ :model_id ] => :environment do |t, args|
    model_id = args[:model_id] || "openai-model"
    client = typesense_client

    response = client.delete("nl_search_models/#{model_id}")

    if response.success?
      puts "NL Search model '#{model_id}' deleted!"
    else
      puts "Error: #{response.status} - #{response.body}"
    end
  end

  private

  def typesense_client
    config = Rails.application.credentials.typesense
    host = config[:host] || "localhost"
    port = config[:port] || "8108"
    protocol = config[:protocol] || "http"
    api_key = config[:api_key]

    Faraday.new(url: "#{protocol}://#{host}:#{port}") do |builder|
      builder.request :json
      builder.response :json
      builder.headers["X-TYPESENSE-API-KEY"] = api_key
    end
  end
end
