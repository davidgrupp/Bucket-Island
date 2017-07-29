defmodule BucketIsland.Models.ClickTotals do
    @derive ExAws.Dynamo.Encodable
    defstruct [:id, :total_bucket_island, :total_other_island, :total_swamp, :total_forest, :total_plains, :total_mountain, :total_clicks, :part]

    def update_total_clicks(totals) do 
        total_clicks = (totals.total_bucket_island + totals.total_other_island + totals.total_swamp + totals.total_forest + totals.total_plains + totals.total_mountain)
        Map.update!(totals, :total_clicks, fn _ -> total_clicks end)
    end

    def empty do
        %BucketIsland.Models.ClickTotals{
            total_bucket_island: 0,
            total_other_island: 0,
            total_swamp: 0,
            total_forest: 0,
            total_plains: 0,
            total_mountain: 0,
            total_clicks: 0
        }
    end

    def merge(clicks1, clicks2) do
        merged = %BucketIsland.Models.ClickTotals{
            total_bucket_island: clicks1.total_bucket_island + clicks2.total_bucket_island,
            total_other_island: clicks1.total_other_island + clicks2.total_other_island,
            total_swamp: clicks1.total_swamp + clicks2.total_swamp,
            total_forest: clicks1.total_forest + clicks2.total_forest,
            total_plains: clicks1.total_plains + clicks2.total_plains,
            total_mountain: clicks1.total_mountain + clicks2.total_mountain
        }
        update_total_clicks(merged)
    end
end