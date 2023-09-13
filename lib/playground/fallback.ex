defmodule Playground.Fallback do
  @moduledoc """
  If process from Processor crashes, this module makes sure to send message to DGA.
  """

  use GenServer

  require Logger

  def start(%{
        imei: imei,
        from_ts: _from_ts,
        to_ts: _to_ts,
        trip_split_interval_in_seconds: _trip_split_interval_in_seconds
      }) do
    Logger.info("Start #{inspect(get_name(imei))}")
    GenServer.start(__MODULE__, imei, name: get_name(imei))
  end

  def get_name(imei) do
    String.to_atom(inspect(__MODULE__) <> "_" <> imei)
  end

  def put(imei) do
    Logger.info("Update #{imei}")
    GenServer.cast(get_name(imei), :put)
  end

  def init(%{
        imei: imei,
        from_ts: from_ts,
        to_ts: to_ts,
        trip_split_interval_in_seconds: trip_split_interval_in_seconds
      }) do
    {:ok,
     %{
       imei: imei,
       from_ts: from_ts,
       to_ts: to_ts,
       trip_split_interval_in_seconds: trip_split_interval_in_seconds,
       ts: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
     }, {:continue, :schedule_check_end_of_processing}}
  end

  def handle_continue(:schedule_check_end_of_processing, state) do
    schedule()
    {:noreply, state}
  end

  def handle_info(:check_end_of_processing, state) do
    now = now()
    Logger.info("In handle_info, check_end_of_processing")
    Logger.info("now - ts #{now - state.ts}")
    Logger.info("interval #{state.trip_split_interval_in_seconds}")
    Logger.info("#{now() - state.ts > state.trip_split_interval_in_seconds * 1000 }")
    if now() - state.ts > state.trip_split_interval_in_seconds * 1000 do
      Logger.info("Send to DGA: #{inspect(state.imei)}")
      {:stop, :normal, state}
    else
      Logger.info("reschedule")
      schedule()
      {:noreply, state}
    end
  end

  def handle_cast(:put, state) do
    Logger.info("Set the ts of state to now()")
    {:noreply, %{state | ts: now()}}
  end

  def terminate(reason, state) do
    Logger.info("In terminate, reason: #{inspect(reason)}")
    {:ok, state}
  end

  defp schedule() do
    Logger.info("In schedule")
    Process.send_after(self(), :check_end_of_processing, 30_000)
  end

  defp now() do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
