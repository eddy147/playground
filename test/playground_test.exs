defmodule PlaygroundTest do
  use ExUnit.Case
  doctest Playground

  test "see if the fallback works" do
    imeis = ["AAAAA", "BBBBB"]

    for imei <- imeis do
      {:ok, _pid} = Playground.Processor.start_link(imei)
      
    end
  end
end
