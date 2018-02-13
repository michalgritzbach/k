defmodule CLITest do
  use ExUnit.Case
  doctest Katastr.CLI

  import Katastr.CLI, only: [parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "two-value tuple returned when parsing correct arguments" do
    assert parse_args(["123456", "st12", "30", "400"]) == {"123456", ["st12", "30", "400"]}
  end
end
