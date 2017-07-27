defmodule BucketIsland.Repositories.ClicksRepository do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, {})
    end

    def get(pid), do: GenServer.call(pid, :get)
    def create(pid, clicks), do: GenServer.cast(pid, {:create, clicks})

    def handle_call(:get, _from, clicks) do
        [first|t] = 
            ExAws.Dynamo.scan("Clicks", limit: 1)
            |> ExAws.stream!
            |> Enum.take 1

        first_clicks = %BucketIsland.Models.ClickTotals{
            id: first["id"]["S"] |> String.to_integer,
            total_bucket_island: first["total_bucket_island"]["N"] |> String.to_integer,
            total_other_island: first["total_other_island"]["N"] |> String.to_integer,
            total_swamp: first["total_swamp"]["N"] |> String.to_integer,
            total_forest: first["total_forest"]["N"] |> String.to_integer,
            total_plains: first["total_plains"]["N"] |> String.to_integer,
            total_mountain: first["total_mountain"]["N"] |> String.to_integer
            }
        {:reply, first_clicks, clicks}
    end

    def handle_cast({:create, clicks}, totals) do
        ExAws.Dynamo.put_item("Clicks", clicks)
            |> ExAws.request!
        {:noreply, totals}
    end
end