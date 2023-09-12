defmodule Playground.Fallback do
  @moduledoc """
  If process from Processor crashes, this module makes sure to send message to DGA.
  """

  use GenServer

  require Logger

  def start(%{imei: imei, from_ts: _from_ts, to_ts: _to_ts, trip_split_interval_in_seconds: _trip_split_interval_in_seconds}) do
    GenServer.start(__MODULE__, imei, name: get_name(imei))
  end

  def init(%{imei: imei, from_ts: from_ts, to_ts: to_ts, trip_split_interval_in_seconds: trip_split_interval_in_seconds}) do
    schedule()
    {:ok, %{imei: imei, from_ts: from_ts, to_ts: to_ts, trip_split_interval_in_seconds: trip_split_interval_in_seconds, ts: DateTime.utc_now() |> DateTime.to_unix(:millisecond)}}
  end

  def get_name(imei) do
    String.to_atom(inspect(__MODULE__) <> "_" <> imei)
  end


  def handle_info(:check_end_of_processing, _from, state) do
    if now() - state.ts > state.trip_split_interval_in_seconds * 1000 do
      Logger.info("Send to DGA: #{inspect state}")
      {:stop, :normal, state}
    else
      schedule()
      {:noreply, state}
    end

  end

  defp schedule() do
    Process.send_after(self(), :check_end_of_processing, 120_000)
  end

  defp now() do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end

end
