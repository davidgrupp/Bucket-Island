defmodule BucketIsland.Services.TeamSelectionCache do
    use GenServer
    
    def start_link() do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def init(_) do
        Registry.register(:bucket_island_registry, :team_selection_cache, nil)
        {:ok, %{ bucket_island: 0, other_island: 0, forest: 0, mountain: 0, plains: 0, swamp: 0 } }
    end

    def join_team(pid, :bucket_island), do: GenServer.cast(pid, {:join_team, :bucket_island})
    def join_team(pid, :other_island), do: GenServer.cast(pid, {:join_team, :other_island})
    def join_team(pid, :forest), do: GenServer.cast(pid, {:join_team, :forest})
    def join_team(pid, :mountain), do: GenServer.cast(pid, {:join_team, :mountain})
    def join_team(pid, :plains), do: GenServer.cast(pid, {:join_team, :plains})
    def join_team(pid, :swamp), do: GenServer.cast(pid, {:join_team, :swamp})
    def get_team_counts(pid), do: GenServer.call(pid, :get_team_counts)

    def handle_call(:get_team_counts, _from, team_counts), do: {:reply, team_counts, team_counts}

    def handle_cast({:join_team, team}, team_counts) do
        updated_team_counts = Map.update!(team_counts, team, & &1 + 1)
        {:noreply, updated_team_counts}
    end

end