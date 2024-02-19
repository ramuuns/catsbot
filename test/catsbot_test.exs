defmodule CatsbotTest do
  use ExUnit.Case
  doctest Catsbot

  test "greets the world" do
    assert Catsbot.hello() == :world
  end
end
