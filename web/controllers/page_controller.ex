defmodule BucketIsland.PageController do
  use BucketIsland.Web, :controller

  def index(conn, _params) do
    [{teams_pid, _}] = Registry.lookup(:bucket_island_registry, :team_selection_cache)
    team_counts = BucketIsland.Services.TeamSelectionCache.get_team_counts(teams_pid)
    [{clicks_pid, _}] = Registry.lookup(:bucket_island_registry, :click_totals_cache)
    click_totals = BucketIsland.Services.ClickTotalsCache.totals(clicks_pid)
    
    user_cookie = conn.cookies["userxx"]
    user_id = 
    if user_cookie == nil do
      user_val = %{user_id: UUID.uuid1} |> Cipher.cipher
      conn
      |> put_resp_cookie("userxx", user_val, max_age: 60*60*24*365*5)
      user_val
    else
      user_cookie
    end

    conn
    |> put_resp_cookie("userxx", user_id, max_age: 60*60*24*365*5)
    |> assign(:click_totals, click_totals)
    |> assign(:team_counts, team_counts)
    |> assign(:user_id, user_id)
    |> render("index.html")
  end
end
