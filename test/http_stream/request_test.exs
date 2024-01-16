defmodule HTTPStream.RequestTest do
  use ExUnit.Case

  alias HTTPStream.Request

  describe "new/3" do
    test "generates the correct structure" do
      url = "http://localhost:4000"

      assert %Request{
               scheme: :http,
               host: "localhost",
               port: 4000,
               path: "/",
               path_with_query: "/",
               method: "GET",
               headers: [],
               query: [],
               body: %{}
             } == Request.new("GET", url)
    end

    test "correctly parses query params" do
      url = "http://localhost:4000"
      query = [id: 1, filter: true]

      assert %Request{
               scheme: :http,
               host: "localhost",
               port: 4000,
               path: "/",
               path_with_query: "/?id=1&filter=true",
               method: "GET",
               headers: [],
               query: [id: 1, filter: true],
               body: %{}
             } == Request.new("GET", url, query: query)
    end

    test "correctly parses query params in a url" do
      url = "http://localhost:4000?foo=bar&bar=baz"

      assert %Request{
               scheme: :http,
               host: "localhost",
               port: 4000,
               path: "/",
               path_with_query: "/?bar=baz&foo=bar",
               method: "GET",
               headers: [],
               query: [bar: "baz", foo: "bar"],
               body: %{}
             } == Request.new("GET", url)
    end

    test "merges argument query params and url query params" do
      url = "http://localhost:4000?foo=bar&bar=baz"
      query = [id: 1, filter: true]

      assert %Request{
               scheme: :http,
               host: "localhost",
               port: 4000,
               path: "/",
               path_with_query: "/?bar=baz&foo=bar&id=1&filter=true",
               method: "GET",
               headers: [],
               query: [bar: "baz", foo: "bar", id: 1, filter: true],
               body: %{}
             } == Request.new("GET", url, query: query)
    end

    test "prioritizes argument query over url query params" do
      url = "http://localhost:4000?foo=bar&bar=baz"
      query = [id: 1, foo: "baz"]

      assert %Request{
               scheme: :http,
               host: "localhost",
               port: 4000,
               path: "/",
               path_with_query: "/?bar=baz&id=1&foo=baz",
               method: "GET",
               headers: [],
               query: [bar: "baz", id: 1, foo: "baz"],
               body: %{}
             } == Request.new("GET", url, query: query)
    end

    test "correctly parses body params" do
      url = "http://localhost:4000"
      params = %{id: 1, filter: true}

      assert %Request{
               scheme: :http,
               host: "localhost",
               port: 4000,
               path: "/",
               path_with_query: "/",
               method: "POST",
               headers: [],
               body: params
             } == Request.new("POST", url, body: params)
    end
  end

  describe "url_for/1" do
    test "generates the correct URL" do
      url = "http://localhost:4000"
      query = [id: 1, filter: true]
      request = Request.new("GET", url, query: query)

      expected_url = "http://localhost:4000/?id=1&filter=true"
      assert expected_url == Request.url_for(request)
    end
  end
end
