defmodule BucketIsland.Services.TeamSelectionCache do
    use GenServer
    
    def start_link() do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def init(_) do
        Registry.register(:bucket_island_registry, :team_selection_cache, nil)
        {:ok, %{ total: 0, bucket_island: 0, other_island: 0, forest: 0, mountain: 0, plains: 0, swamp: 0 } }
    end

    def join_team(pid, :bucket_island), do: GenServer.cast(pid, {:join_team, :bucket_island})
    def join_team(pid, :other_island), do: GenServer.cast(pid, {:join_team, :other_island})
    def join_team(pid, :forest), do: GenServer.cast(pid, {:join_team, :forest})
    def join_team(pid, :mountain), do: GenServer.cast(pid, {:join_team, :mountain})
    def join_team(pid, :plains), do: GenServer.cast(pid, {:join_team, :plains})
    def join_team(pid, :swamp), do: GenServer.cast(pid, {:join_team, :swamp})
    
    def leave_team(_, nil), do: nil
    def leave_team(pid, :bucket_island), do: GenServer.cast(pid, {:leave_team, :bucket_island})
    def leave_team(pid, :other_island), do: GenServer.cast(pid, {:leave_team, :other_island})
    def leave_team(pid, :forest), do: GenServer.cast(pid, {:leave_team, :forest})
    def leave_team(pid, :mountain), do: GenServer.cast(pid, {:leave_team, :mountain})
    def leave_team(pid, :plains), do: GenServer.cast(pid, {:leave_team, :plains})
    def leave_team(pid, :swamp), do: GenServer.cast(pid, {:leave_team, :swamp})

    def get_team_counts(pid), do: GenServer.call(pid, :get_team_counts)

    def handle_call(:get_team_counts, _from, team_counts) do 
        updated_team_counts = update_totals(team_counts)
        {:reply, updated_team_counts, updated_team_counts}
    end

    def handle_cast({:join_team, team}, team_counts) do
        updated_team_counts = Map.update!(team_counts, team, & &1 + 1)
        {:noreply, updated_team_counts}
    end
    
    def handle_cast({:leave_team, team}, team_counts) do
        updated_team_counts = Map.update!(team_counts, team, & &1 - 1)
        {:noreply, updated_team_counts}
    end

    def update_totals(teams) do 
        total_clicks = (teams.bucket_island + teams.other_island + teams.swamp + teams.forest + teams.plains + teams.mountain)
        Map.update!(teams, :total, fn _ -> total_clicks end)
    end
end