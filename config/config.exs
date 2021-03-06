# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :bucketisland, BucketIsland.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rZFKfOhvKxv2W1qOVoLRJtr3d+CfbWjCp33sx4dMixA9VkYRWnmd369AHuwo+Hwg",
  render_errors: [view: BucketIsland.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BucketIsland.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_aws,
  debug_requests: false,
  region: "us-west-2"

config :ex_aws, :dynamodb,
  scheme: "https://",
  host: "dynamodb.us-west-2.amazonaws.com",
  port: 443,
  region: "us-west-2"


config :bucketisland,
  total_clicks_interval: 3000,
  team_counts_interval: 3000,
  click_totals_cache_commit_interval: 60_000,
  click_totals_cache_user_commit_interval: 300_000,
  click_totals_table_name: "ClickTotals"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
