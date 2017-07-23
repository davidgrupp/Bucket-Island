defmodule BucketIsland.PageController do
  use BucketIsland.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
