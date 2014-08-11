defmodule GardenTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "displays welcome message" do
    assert capture_io(fn -> Garden.start(:normal, []) end) =~ ~r/Welcome/
  end
end
