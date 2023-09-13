defmodule Playground.Processor do
  @moduledoc false
alias Playground.Fallback

  use GenServer

  require Logger

  def start_link(imei) do
    Logger.info("Start #{inspect(get_name(imei))}")
    GenServer.start_link(__MODULE__, imei, name: get_name(imei))
    GenServer.start(Fallback, %{
      imei: imei,
      from_ts: now() - 123_456,
      to_ts: now(),
      trip_split_interval_in_seconds: 60,
      ts: now()
    }, name: Fallback.get_name(imei))
  end

  def init(imei) do
    state = %{
      imei: imei,
      from_ts: now() - 123_456,
      to_ts: now(),
      trip_split_interval_in_seconds: 60
    }

    Fallback.put(imei)
    {:ok, state}
  end

  def update(imei) do
    GenServer.cast(get_name(imei), :update)
  end

  def handle_cast(:update, state) do
    Fallback.put(state.imei)

    {:noreply, state}
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end

  defp get_name(imei) do
    String.to_atom(inspect(__MODULE__) <> "_" <> imei)
  end
end
