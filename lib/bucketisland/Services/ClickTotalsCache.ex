defmodule OptionCalc.Utilities.GenDataCache do
    use GenServer
    
    @timeout 1000

    def start_link() do
        # get initiall values
        {:ok, pid} = GenServer.start_link(__MODULE__, :ok, opts)
        :timer.send_interval(@timeout, pid, :commit)
        {:ok, pid}
    end

    def handle_call(:totals, _from, ${
        total_bucket_island: total_bucket_island,
        total_other_island: total_other_island,
        total_swamp: total_swamp,
        total_forest: total_forest,
        total_plains: total_plains,
        total_mountain: total_mountain,
    } = totals) do
        {:reply, totals, totals}
    end

    def handle_cast(:commit, ${
        total_bucket_island: total_bucket_island,
        total_other_island: total_other_island,
        total_swamp: total_swamp,
        total_forest: total_forest,
        total_plains: total_plains,
        total_mountain: total_mountain,
    } = totals) do
        # commit totals to dynamo
        {:noreply, totals}
    end

    def increment_bucket_island(pid, increment), do GenServer.cast(pid, {:increment_bucket_island, increment})
    def increment_other_island(pid, increment), do GenServer.cast(pid, {:increment_other_island, increment})
    def increment_swamp(pid, increment), do GenServer.cast(pid, {:increment_swamp, increment})
    def increment_forest(pid, increment), do GenServer.cast(pid, {:increment_forest, increment})
    def increment_plains(pid, increment), do GenServer.cast(pid, {:increment_plains, increment})
    def increment_mountain(pid, increment), do GenServer.cast(pid, {:increment_mountain, increment})

    def handle_cast({:increment_bucket_island, increment}, ${ total_bucket_island: total_bucket_island } = totals) do
        updated_totals = Map.update(totals, :total_bucket_island, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_other_island, increment}, ${ total_other_island: total_other_island } = totals) do
        updated_totals = Map.update(totals, :total_other_island, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_swamp, increment}, ${ total_swamp: total_swamp } = totals) do
        updated_totals = Map.update(totals, :total_swamp, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_forest, increment}, ${ total_forest: total_forest } = totals) do
        updated_totals = Map.update(totals, :total_forest, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_plains, increment}, ${ total_plains: total_plains } = totals) do
        updated_totals = Map.update(totals, :total_plains, &(&1 + increment))
        {:noreply, updated_totals}
    end

    def handle_cast({:increment_mountain, increment}, ${ total_mountain: total_mountain } = totals) do
        updated_totals = Map.update(totals, :total_mountain, &(&1 + increment))
        {:noreply, updated_totals}
    end
end