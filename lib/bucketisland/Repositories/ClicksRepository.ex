defmodule BucketIsland.Repositories.ClicksRepository do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, {})
    end

    def get(pid), do: GenServer.call(pid, :get)
    def create(pid, clicks), do: GenServer.cast(pid, {:create, clicks})

    def handle_call(:get, _from, clicks) do
        #[first|_] = 
        x =    ExAws.Dynamo.query("Clicks",
                limit: 1,
                scan_index_forward: false,
                key_condition_expression: "part = :part",
                expression_attribute_values: [part: 1],
                index_name: "part-total_clicks-index")
            |> ExAws.request!
        IO.inspect x

        #first_clicks = %BucketIsland.Models.ClickTotals{
        #    id: first["id"]["S"] |> String.to_integer,
        #    total_bucket_island: first["total_bucket_island"]["N"] |> String.to_integer,
        #    total_other_island: first["total_other_island"]["N"] |> String.to_integer,
        #    total_swamp: first["total_swamp"]["N"] |> String.to_integer,
        #    total_forest: first["total_forest"]["N"] |> String.to_integer,
        #    total_plains: first["total_plains"]["N"] |> String.to_integer,
        #    total_mountain: first["total_mountain"]["N"] |> String.to_integer
        #    }
        {:reply, x, clicks}
    end

    def handle_cast({:create, clicks}, totals) do
        totals = BucketIsland.Models.ClickTotals.update_total_clicks(totals)

        ExAws.Dynamo.put_item("Clicks", clicks)
            |> ExAws.request!
        {:noreply, totals}
    end
end