defmodule EetoulCReadOnlyCommandsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Eetoul.CLI
  alias Eetoul.Test.SampleSpecRepo

  setup_all do
    {a, b, c} = :erlang.timestamp
    :random.seed a, b, c
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    case SampleSpecRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  test "`cat first-release` prints release spec", meta do
    call = fn ->
      CLI.cli_command meta[:repo], ["cat", "first-release"]
    end
    assert capture_io(call) == "checkout first-branch\ntake first-branch\n"
  end
end
