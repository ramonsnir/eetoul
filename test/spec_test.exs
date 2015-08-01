defmodule EetoulSpecTest do
  use ExUnit.Case, async: true
  alias Eetoul.Spec
  alias Eetoul.Spec.ParseError
  alias Eetoul.Test.SampleTreeRepo

  setup_all do
    {a, b, c} = :erlang.timestamp
    :random.seed a, b, c
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    case SampleTreeRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  test "parse valid spec" do
    spec = "checkout first\ntake second\ntake-squash third Third tag is here\ntake-merge fourth\n"
    expected = [
      {:checkout, "first"},
      {:take, "second", :default},
      {:take, "third", {:squash, "Third tag is here"}},
      {:take, "fourth", :merge}
    ]
    assert expected == Spec.parse(spec)
  end

  test "`checkout` needs arguments" do
    assert_raise ParseError, "`checkout` expects a reference argument.", fn ->
      Spec.parse "checkout"
    end
  end

  test "`checkout` needs only one argument" do
    assert_raise ParseError, "`checkout` does not expect a message argument.", fn ->
      Spec.parse "checkout foo bar"
    end
  end

  test "`take-squash` needs arguments" do
    assert_raise ParseError, "`take-squash` expects a reference argument.", fn ->
      Spec.parse "take-squash"
    end
  end

  test "`take-squash` needs two arguments" do
    assert_raise ParseError, "`take-squash` expects a message argument.", fn ->
      Spec.parse "take-squash foo"
    end
  end
end
