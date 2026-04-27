import Config

config :codecrafters_redis, ecto_repos: [Repo]

config :codecrafters_redis, Repo,
  database: "codecrafters_redis_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10
