defmodule BucketIsland.Models.ClickTotals do
    @derive ExAws.Dynamo.Encodable
    defstruct [:id, :total_bucket_island, :total_other_island, :total_swamp, :total_forest, :total_plains, :total_mountain]
end