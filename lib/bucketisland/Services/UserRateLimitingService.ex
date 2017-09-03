defmodule BucketIsland.Services.UserRateLimitingService do
    use GenServer
    
    @maxClicksPerSecond 20
    @maxClicksPerMinute 60*10
    @maxClicksPerHour   60*60*3
    @maxClicksPerDay    60*60*24*2

    def start_link(user_id) do
        GenServer.start_link(__MODULE__, :ok, [user_id])
    end

    def init(user_id) do
        {:ok, %{last_date: DateTime.utc_now,
                clicks_per_second: %BucketIsland.Models.RateLimit {},
                clicks_per_minute: %BucketIsland.Models.RateLimit {},
                clicks_per_hour: %BucketIsland.Models.RateLimit {},
                clicks_per_hour: %BucketIsland.Models.RateLimit {} } }
    end

    def handle_call(:exceeded_limits, _from, limits) do
        now = DateTime.utc_now
        date_diff = DateTime.diff(now, limits.last_date, :millisecond)

        update_rate_limits(limits.clicks_per_second, date_diff, now, 1000, @maxClicksPerSecond)

        #{:reply, merged, totals}
        {:reply, {}, limits}
    end

    def update_rate_limits(rate_limits, date_diff, now, milliseconds_per_timespan, max_clicks) do
        min_timespan = div(milliseconds_per_timespan, max_clicks)
        times_exceeded_timespan = div(date_diff, min_timespan)
        if times_exceeded_timespan == 0 do
            new_increment = rate_limits.increment + 2
        else
            new_increment = -1 * times_exceeded_timespan
        end
        rate_limits = update_limit_run(rate_limits, times_exceeded_timespan)
        #new_total = rate_limit.total + new_increment
    end

    def update_limit_run(rate_limit, times_exceeded_timespan) do
        Map.update(rate_limit, :pos_run, fn _ -> 0 end)
        |> Map.update(:neg_run, & &1 -1)
    end

    def update_limit_run(rate_limit, 0) do
        Map.update(rate_limit, :pos_run, & &1 -1)
        |> Map.update(:neg_run, fn _ -> 0 end)
    end
end