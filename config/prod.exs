use Mix.Config

config :logger, :console, level: :warn,
format: "$level: $message\n",
colors: [enabled: true]
