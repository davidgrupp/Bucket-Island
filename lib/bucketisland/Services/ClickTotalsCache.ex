defmodule OptionCalc.Utilities.GenDataCache do
  
    @timeout 1000

    def start_link() do
        # get initiall values
        {:ok, pid} = Agent.start_link(fn-> %{ total_bucket_island: 0, total_other: 0 } end, name: __MODULE__)
        :timer.send_interval(@timeout, :commit)
    end

    def get_value_async(process, key, query) do
        cached = Agent.get(process, fn x -> x[key] end)
    end

    def get_value(process, query) do
        cached = Agent.get(process, fn x -> x end)
    end

    def set_value(process, value) do
        cached_value = %{ value: value, cached_on: DateTime.utc_now, status: :ready }
        Agent.update(process, fn state -> Map.put(state, key, cached_value) end)
    end

    def is_valid(cached_data) do
        cached_on = cached_data.cached_on |> DateTime.to_unix
        cached_on + @timeout > DateTime.utc_now |> DateTime.to_unix
    end

end