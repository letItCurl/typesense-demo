# Typesense Demo

A Rails application demonstrating Typesense's Natural Language Search with a cars dataset.

## References

- [Live Demo](https://natural-language-search-cars-genkit.typesense.org/)
- [Typesense Natural Language Search Docs](https://typesense.org/docs/29.0/api/natural-language-search.html)
- [typesense-rails gem](https://github.com/typesense/typesense-rails)
- [Cars Dataset (Kaggle)](https://www.kaggle.com/datasets/rupindersinghrana/car-features-and-prices-dataset)

## Setup

### 1. Configure Credentials

```bash
EDITOR='code --wait' bin/rails credentials:edit --environment development
```

Add the following:

```yaml
typesense:
  host: localhost
  port: "8108"
  protocol: http
  api_key: xyz123
  openai_api_key: sk-your-openai-api-key
```

### 2. Setup Database & Seed Data

```bash
bin/rails db:create db:migrate db:seed
```

The seed task imports cars from `db/fixtures/cars.jsonl` with a progress bar.

### 3. Start the Application

```bash
bin/dev
```

This starts the Rails server, Typesense (via Docker), and other services defined in `Procfile.dev`.

### 4. Index Data in Typesense

```bash
bin/rails typesense:reindex_cars
```

### 5. Create Natural Language Search Model

```bash
bin/rails typesense:create_nl_model
```

### 6. Verify NL Search Setup

```bash
bin/rails typesense:ping_nl
```

This tests the Typesense connection, verifies NL Search support, and performs a sample query.

## Rake Tasks

### Status & Monitoring

| Task | Description |
|------|-------------|
| `bin/rails typesense:status` | Check collection state, document counts, schema, and sync status |

### Indexing

| Task | Description |
|------|-------------|
| `bin/rails typesense:reindex_cars` | Reindex all cars (zero-downtime, uses alias) |
| `bin/rails typesense:reindex_cars!` | Clear and reindex all cars (destructive) |

### Natural Language Search Models

| Task | Description |
|------|-------------|
| `bin/rails typesense:ping_nl` | Test connection and NL Search support |
| `bin/rails typesense:create_nl_model` | Create OpenAI NL search model |
| `bin/rails typesense:list_nl_models` | List all NL search models |
| `bin/rails typesense:delete_nl_model` | Delete the default NL model |
| `bin/rails typesense:delete_nl_model[model_id]` | Delete a specific NL model |

## Example Natural Language Queries

Once set up, you can search using natural language:

- "A honda or BMW with at least 200hp, rear wheel drive, from 20K to 50K"
- "Show me the most powerful car you have"
- "High performance Italian cars, above 700hp"
- "I don't know how to drive a manual"
- "Fuel efficient sedans under 30K"

Typesense + OpenAI will automatically parse these into filters, sorts, and queries.
