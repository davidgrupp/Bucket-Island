defmodule BucketIsland.PageController do
  use BucketIsland.Web, :controller

  def index(conn, _params) do
    [{teams_pid, _}] = Registry.lookup(:bucket_island_registry, :team_selection_cache)
    team_counts = BucketIsland.Services.TeamSelectionCache.get_team_counts(teams_pid)
    [{clicks_pid, _}] = Registry.lookup(:bucket_island_registry, :click_totals_cache)
    click_totals = BucketIsland.Services.ClickTotalsCache.totals(clicks_pid)
    conn
    |> assign(:click_totals, click_totals)
    |> assign(:team_counts, team_counts)
    |> render("index.html")
  end
end
