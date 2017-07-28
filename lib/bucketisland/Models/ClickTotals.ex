defmodule BucketIsland.Models.ClickTotals do
    @derive ExAws.Dynamo.Encodable
    defstruct [:id, :total_bucket_island, :total_other_island, :total_swamp, :total_forest, :total_plains, :total_mountain, :total_clicks]

    def update_total_clicks(totals) do 
        total_clicks
            = totals.total_bucket_island
            + totals.total_other_island
            + totals.total_swamp
            + totals.total_forest
            + totals.total_plains
            + totals.total_mountain
        Map.update!(totals, :total_clicks, fn x -> total_clicks end)
    end
end