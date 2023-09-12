defmodule Playground.Processor do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(imei) do
    Logger.info("Start #{inspect get_name(imei)}")
    GenServer.start_link(__MODULE__, imei, name: get_name(imei))
  end

  def init(imei) do
    state = %{imei: imei, from_ts: now() - 123456, to_ts: now(), trip_split_interval_in_seconds: 60}
    {:ok, state}
  end

  def update(imei) do
    GenServer.cast(get_name(imei), :update)
  end

  def handle_cast(:update, state) do
    GenServer.cast(Playground.Fallback, {:put, state})

    {:noreply, state}
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end

  defp get_name(imei) do
    String.to_atom(inspect(__MODULE__) <> "_" <> imei)
  end
end
