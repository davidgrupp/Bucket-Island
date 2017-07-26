defmodule BucketIsland.Services.ClickTotalsCache do
    use GenServer
    
    @timeout 1000

    def start_link() do
        # get initiall values
        {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
        :timer.send_interval(@timeout, pid, :commit)
        {:ok, pid}
    end

    def increment_bucket_island(pid, increment), do: GenServer.cast(pid, {:increment_bucket_island, increment})
    def increment_other_island(pid, increment), do: GenServer.cast(pid, {:increment_other_island, increment})
    def increment_swamp(pid, increment), do: GenServer.cast(pid, {:increment_swamp, increment})
    def increment_forest(pid, increment), do: GenServer.cast(pid, {:increment_forest, increment})
    def increment_plains(pid, increment), do: GenServer.cast(pid, {:increment_plains, increment})
    def increment_mountain(pid, increment), do: GenServer.cast(pid, {:increment_mountain, increment})
    def totals(pid), do: GenServer.call(pid, :totals)
    def commit(pid), do: GenServer.cast(pid, :commit)

    def init(_) do
        {:ok, %BucketIsland.Models.ClickTotals{
            total_bucket_island: 0,
            total_other_island: 0,
            total_swamp: 0,
            total_forest: 0,
            total_plains: 0,
            total_mountain: 0
            }
        }
    end

    def handle_call(:totals, _from, totals) do
        {:reply, totals, totals}
    end

    def handle_cast(:commit, totals) do
        # commit totals to dynamo
        {:noreply, totals}
    end

    def handle_cast({:increment_bucket_island, increment}, totals) do
        updated_totals = Map.update!(totals, :total_bucket_island, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_other_island, increment}, totals) do
        updated_totals = Map.update!(totals, :total_other_island, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_swamp, increment}, totals) do
        updated_totals = Map.update!(totals, :total_swamp, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_forest, increment}, totals) do
        updated_totals = Map.update!(totals, :total_forest, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_plains, increment}, totals) do
        updated_totals = Map.update!(totals, :total_plains, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_mountain, increment}, totals) do
        updated_totals = Map.update!(totals, :total_mountain, &(&1 + increment))
        {:noreply, updated_totals}
    end
end