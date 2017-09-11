defmodule BucketIsland.Repositories.ClicksRepository do

    @table_name Application.get_env(:bucketisland, :click_totals_table_name)

    def get_current(partition) do
        response =  ExAws.Dynamo.query(@table_name,
            limit: 1,
            scan_index_forward: false,
            key_condition_expression: "part = :part",
            expression_attribute_values: [part: partition],
            index_name: "part-total_clicks-index")
        |> ExAws.request!
        IO.puts("aws response: ")
        IO.inspect(response)
        r = case response do
            %{"Count" => count, "Items" => [result]} when count == 1 ->
                %BucketIsland.Models.ClickTotals{
                    total_bucket_island: result["total_bucket_island"]["N"] |> String.to_integer,
                    total_other_island: result["total_other_island"]["N"] |> String.to_integer,
                    total_swamp: result["total_swamp"]["N"] |> String.to_integer,
                    total_forest: result["total_forest"]["N"] |> String.to_integer,
                    total_plains: result["total_plains"]["N"] |> String.to_integer,
                    total_mountain: result["total_mountain"]["N"] |> String.to_integer,
                    total_clicks: result["total_clicks"]["N"] |> String.to_integer,
                    part: result["part"]["S"]
                }
            _ ->
                BucketIsland.Models.ClickTotals.empty(partition)
        end
        IO.puts("result")
        r
    end

    def create(clicks) do
        clicks = BucketIsland.Models.ClickTotals.update_total_clicks(clicks)
        clicks = Map.update!(clicks, :id, fn _ -> UUID.uuid1 end)

        #Task.async(fn ->
        Task.start(fn ->
            ExAws.Dynamo.put_item(@table_name, clicks)
                |> ExAws.request!
        end)
    end
end