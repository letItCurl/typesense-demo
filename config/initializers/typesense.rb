Typesense.configuration = {
  nodes: [ {
    host: Rails.application.credentials.dig(:typesense, :host) || "localhost",
    port: Rails.application.credentials.dig(:typesense, :port) || "8108",
    protocol: Rails.application.credentials.dig(:typesense, :protocol) || "http"
  } ],
  api_key: Rails.application.credentials.dig(:typesense, :api_key) || "xyz123",
  connection_timeout_seconds: 2,
  pagination_backend: :pagy
}
