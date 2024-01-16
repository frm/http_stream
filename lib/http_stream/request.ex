defmodule HTTPStream.Request do
  @moduledoc """
  Struct that represents a request.

  Fields:

  * `scheme`: `atom()` - e.g. `:http`
  * `host`: `binary()` - e.g. `"localhost"`
  * `port`: `integer()` - e.g. `80`
  * `path`: `binary()` - e.g `"/users/1/avatar.png"`
  * `path_with_query`: `binary()` - e.g `"/users/1/avatar.png?foo=bar"`
  * `method`: `String.t()` - e.g. `"GET"`
  * `headers`: `keyword()` - e.g. `[authorization: "Bearer 123"]`
  * `query`: `keyword()` - e.g. `[id: "1"]`
  * `body`: `map()` - e.g. `%{id: "1"}`
  """

  @supported_methods ~w(GET OPTIONS HEAD TRACE POST PUT PATCH DELETE)

  defstruct scheme: nil,
            host: nil,
            port: 80,
            path: "/",
            path_with_query: "/",
            method: "GET",
            headers: [],
            query: [],
            body: %{}

  @type t :: %__MODULE__{
          scheme: atom() | nil,
          host: binary() | nil,
          port: integer(),
          path: binary(),
          path_with_query: binary(),
          method: binary(),
          headers: keyword(),
          query: keyword(),
          body: map()
        }

  @doc """
  Parses a given URL and uses a given method to generate a valid
  `HTTPStream.Request` struct.

  Supported options:

  * `headers` - HTTP headers to be sent.
  * `body` - Body of the HTTP request. This will be the request `query` field
  if the method is one of "GET", "TRACE", "HEAD", "OPTIONS" and "DELETE".

  This function raises an `ArgumentError` if the HTTP method is unsupported or
  the `url` argument isn't a string.
  """
  @spec new(String.t(), String.t(), keyword()) :: t() | no_return()
  def new(method, url, opts \\ [])

  def new(method, url, opts)
      when is_binary(url) and method in @supported_methods do
    uri = URI.parse(url)
    scheme = String.to_atom(uri.scheme)
    headers = Keyword.get(opts, :headers, [])
    body = Keyword.get(opts, :body, %{})
    query_from_uri = query_from_uri(uri)
    query = Keyword.merge(query_from_uri, Keyword.get(opts, :query, []))
    path = uri.path || "/"
    path_with_query = encode_query_params(path, query)

    %__MODULE__{
      scheme: scheme,
      host: uri.host,
      port: uri.port,
      path: path,
      path_with_query: path_with_query,
      method: method,
      headers: headers,
      query: query,
      body: body
    }
  end

  def new(method, _, _) when method not in @supported_methods do
    supported_methods = Enum.join(@supported_methods, ", ")
    msg = "#{method} is not supported. Supported methods: #{supported_methods}"

    raise ArgumentError, msg
  end

  def new(_, _, _) do
    raise ArgumentError, "URL must be a string"
  end

  def url_for(%__MODULE__{
        scheme: scheme,
        host: host,
        port: port,
        path_with_query: path_with_query
      }) do
    [
      scheme,
      "://",
      host,
      ":",
      port,
      path_with_query
    ]
    |> Enum.join("")
  end

  defp encode_query_params(path, []), do: path

  defp encode_query_params(path, query) do
    path <> "?" <> URI.encode_query(query)
  end

  defp query_from_uri(%URI{query: nil}), do: []

  defp query_from_uri(%URI{query: query}) do
    query
    |> URI.decode_query()
    |> Enum.into([], fn {k, v} ->
      {String.to_atom(k), v}
    end)
  end
end
