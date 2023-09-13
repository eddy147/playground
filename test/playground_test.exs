defmodule PlaygroundTest do
  use ExUnit.Case
  doctest Playground

  test "see if the fallback works" do
    imeis = ["AAAAA", "BBBBB"]

    for imei <- imeis do
      {:ok, _pid} = Playground.Processor.start_link(imei)
    end

    # wait for 1.5 seconds > 1 second, so the fallback should kick in
    :timer.sleep(1500)
  end
end
