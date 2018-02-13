defmodule RecordTest do
  use ExUnit.Case
  doctest Katastr

  @tag :skip
  test "greets the world" do
    assert Katastr.hello() == :world
  end
end
