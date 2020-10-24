# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

config :gathering, Gathering.Repo,
  username: "user",
  password: "pass",
  database: "db",
  hostname: "localhost",
  port: 35432,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gathering, Gathering.MTGRepo,
  adapter: Ecto.Adapters.MyXQL,
  database: "db",
  username: "user",
  password: "pass",
  hostname: "localhost",
  port: 3306

# secret_key_base =
#   System.get_env("SECRET_KEY_BASE") ||
#     raise """
#     environment variable SECRET_KEY_BASE is missing.
#     You can generate one by calling: mix phx.gen.secret
#     """

config :gathering, GatheringWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: "9Q5dIklI+q9pJaKfkNpfP2Ml/Gg5e+f9C87NpT2wlDe0I9+HVDNJbUveCNgzyH1c"

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :gathering, GatheringWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
