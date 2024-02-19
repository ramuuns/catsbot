defmodule CatWorker do
  use GenServer

  @impl true
  def init(state) do
    pics_per_day = Application.fetch_env!(:catsbot, :pics_per_day)

    now = DateTime.utc_now()
    midnight = DateTime.new!(Date.utc_today(), ~T[00:00:00], "Etc/UTC")

    hour_offset = Application.fetch_env!(:catsbot, :hour_offset)

    midnight = DateTime.add(midnight, hour_offset, :hour)

    hours = div(24, pics_per_day)

    seconds_until_next = find_time_until_next(midnight, hours, now)

    IO.puts("scheduling next cat photo in #{seconds_until_next} seconds")

    Process.send_after(self(), :post_next, 1000 * seconds_until_next)
    {:ok, state}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def handle_info(:post_next, state) do
    pics_per_day = Application.fetch_env(:catsbot, :pics_per_day)
    hours = div(24, pics_per_day)
    Process.send_after(self(), :post_next, 1000 * 60 * 60 * hours)
    CatPoster.post_next_cat()
    {:noreply, state}
  end

  def find_time_until_next(next, hours, now) do
    if DateTime.compare(next, now) == :lt do
      find_time_until_next(DateTime.add(next, hours, :hour), hours, now)
    else
      DateTime.diff(next, now)
    end
  end
end
