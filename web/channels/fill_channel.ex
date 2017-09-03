defmodule BucketIsland.FillChannel do
  use Phoenix.Channel
  require Logger

  def join("fill:lobby", %{"user_id"=> user_id}, socket) do
    Process.flag(:trap_exit, true)
    #:timer.send_interval(5000, :ping)
    
    :timer.send_interval(Application.get_env(:bucketisland, :total_clicks_interval), :total_clicks)
    :timer.send_interval(Application.get_env(:bucketisland, :team_counts_interval), :team_counts)
    #send(self, {:after_join, message})
    {:ok, %{"user_id" => user_id} } = Cipher.parse(user_id)
    rl_pid = BucketIsland.Services.UserRateLimitingService.start_link(user_id)
    socket =
    socket
    |> assign(:user_id, user_id)
    |> assign(:rl_pid, rl_pid)
	
    {:ok, socket}
  end

  def join("fill:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_info(:total_clicks, socket) do
    [{pid,_}] = Registry.lookup(:bucket_island_registry, :click_totals_cache)
    totals = BucketIsland.Services.ClickTotalsCache.totals(pid)
    push socket, "update:total_clicks", %{user: "SYSTEM", body: totals}
    {:noreply, socket}
  end

  def handle_info(:team_counts, socket) do
    [{pid,_}] = Registry.lookup(:bucket_island_registry, :team_selection_cache)
    team_counts = BucketIsland.Services.TeamSelectionCache.get_team_counts(pid)
    push socket, "update:team_counts", %{user: "SYSTEM", body: team_counts}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    [{pid,_}] = Registry.lookup(:bucket_island_registry, :team_selection_cache)
    BucketIsland.Services.TeamSelectionCache.leave_team(pid, socket.assigns[:team])
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:click", %{ }, socket) do
    [{pid,_}] = Registry.lookup(:bucket_island_registry, :click_totals_cache)
    click_type = socket.assigns[:team]
    handle_click(click_type, pid)
    {:noreply, socket}
  end

  def handle_in("new:jointeam", %{ "team" => team }, socket) do
    teama = get_atom(team)
    [{pid,_}] = Registry.lookup(:bucket_island_registry, :team_selection_cache)
    BucketIsland.Services.TeamSelectionCache.join_team(pid, teama)
    BucketIsland.Services.TeamSelectionCache.leave_team(pid, socket.assigns[:team])
    {:noreply, assign(socket, :team, teama)}
  end

  defp handle_click(:bucket_island, pid), do: BucketIsland.Services.ClickTotalsCache.increment_bucket_island(pid, 1)
  defp handle_click(:other_island, pid), do: BucketIsland.Services.ClickTotalsCache.increment_other_island(pid, 1)
  defp handle_click(:mountain, pid), do: BucketIsland.Services.ClickTotalsCache.increment_mountain(pid, 1)
  defp handle_click(:swamp, pid), do: BucketIsland.Services.ClickTotalsCache.increment_swamp(pid, 1)
  defp handle_click(:plains, pid), do: BucketIsland.Services.ClickTotalsCache.increment_plains(pid, 1)
  defp handle_click(:forest, pid), do: BucketIsland.Services.ClickTotalsCache.increment_forest(pid, 1)

  defp get_atom("bucket_island"), do: :bucket_island
  defp get_atom("other_island"), do: :other_island
  defp get_atom("forest"), do: :forest
  defp get_atom("mountain"), do: :mountain
  defp get_atom("plains"), do: :plains
  defp get_atom("swamp"), do: :swamp

end
