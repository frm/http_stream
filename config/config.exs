import Config

config :http_stream, adapter: HTTPStream.Adapter.HTTPoison

import_config "#{Mix.env()}.exs"
