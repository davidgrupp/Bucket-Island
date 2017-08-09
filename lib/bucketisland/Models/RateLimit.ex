defmodule BucketIsland.Models.RateLimit do
    defstruct [:total, :increment, :pos_run, :neg_run]
end