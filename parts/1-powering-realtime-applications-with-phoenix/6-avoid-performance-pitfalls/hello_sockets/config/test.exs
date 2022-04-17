import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hello_sockets, HelloSocketsWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4002],
  secret_key_base: "gFFhohXwk4ywPg3/IXxD6GPmIuU2Y8sLAMKIcVHa8q6rV5BfGrbK1pCxtv2Bekws",
  server: false

# In test we don't send emails.
config :hello_sockets, HelloSockets.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :statix, HelloSockets.Statix, port: 8127
