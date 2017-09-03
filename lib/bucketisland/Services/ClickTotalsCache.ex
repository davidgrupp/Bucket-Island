defmodule BucketIsland.Services.ClickTotalsCache do
    use GenServer

    def start_link() do
        {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
        :timer.send_interval(Application.get_env(:bucketisland, :click_totals_cache_commit_interval), pid, :commit)
        {:ok, pid}
    end

    def increment_bucket_island(pid, increment), do: GenServer.cast(pid, {:increment_bucket_island, increment})
    def increment_other_island(pid, increment), do: GenServer.cast(pid, {:increment_other_island, increment})
    def increment_swamp(pid, increment), do: GenServer.cast(pid, {:increment_swamp, increment})
    def increment_forest(pid, increment), do: GenServer.cast(pid, {:increment_forest, increment})
    def increment_plains(pid, increment), do: GenServer.cast(pid, {:increment_plains, increment})
    def increment_mountain(pid, increment), do: GenServer.cast(pid, {:increment_mountain, increment})
    def totals(pid), do: GenServer.call(pid, :totals)

    def init(_) do
        Registry.register(:bucket_island_registry, :click_totals_cache, nil)
        current_totals = BucketIsland.Repositories.ClicksRepository.get_current
        {:ok, %{current_totals: current_totals, temp_totals: BucketIsland.Models.ClickTotals.empty} }
    end

    def handle_call(:totals, _from, totals) do
        merged = BucketIsland.Models.ClickTotals.merge(totals.current_totals, totals.temp_totals)
        {:reply, merged, totals}
    end

    def handle_info(:commit, totals) do
        temp_totals_clicks = BucketIsland.Models.ClickTotals.update_total_clicks(totals.temp_totals)
        if temp_totals_clicks.total_clicks > 0 do
            new_current = BucketIsland.Models.ClickTotals.merge(totals.current_totals, totals.temp_totals)
            BucketIsland.Repositories.ClicksRepository.create(new_current)
            {:noreply, %{current_totals: new_current, temp_totals: BucketIsland.Models.ClickTotals.empty}}
        else
            {:noreply, totals}
        end
    end

    def handle_info(_, totals) do
        {:noreply, totals}
    end

    def handle_cast({:increment_bucket_island, increment}, totals) do
        updated_temp_totals = Map.update!(totals.temp_totals, :total_bucket_island, &(&1 + increment))
        updated_totals = Map.update!(totals, :temp_totals, fn _ -> updated_temp_totals end)
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_other_island, increment}, totals) do
        Map.update!(totals.temp_totals, :total_other_island, &(&1 + increment))
        |> handle_increment(totals)
    end

    def handle_cast({:increment_swamp, increment}, totals) do
        Map.update!(totals.temp_totals, :total_swamp, &(&1 + increment))
        |> handle_increment(totals)
    end

    def handle_cast({:increment_forest, increment}, totals) do
        Map.update!(totals.temp_totals, :total_forest, &(&1 + increment))
        |> handle_increment(totals)
    end

    def handle_cast({:increment_plains, increment}, totals) do
        Map.update!(totals.temp_totals, :total_plains, &(&1 + increment))
        |> handle_increment(totals)
    end

    def handle_cast({:increment_mountain, increment}, totals) do
        Map.update!(totals.temp_totals, :total_mountain, &(&1 + increment))
        |> handle_increment(totals)
    end

    defp handle_increment(updated_temp_totals, totals) do
        updated_totals = Map.update!(totals, :temp_totals, fn _ -> updated_temp_totals end)
        {:noreply, updated_totals}
    end
end