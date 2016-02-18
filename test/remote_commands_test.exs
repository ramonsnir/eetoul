defmodule EetoulRemoteCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.Utils
  alias Eetoul.CLI
  alias Eetoul.ManualCommands
  alias Eetoul.Test.SampleRemoteRepo

  setup_all do
    Utils.seed
    :ok
  end

  setup do
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    remote_path = "tmp-#{__MODULE__}-remote-#{:random.uniform 1000000}"
    File.rm_rf path; File.rm_rf remote_path
    on_exit fn -> File.rm_rf path; File.rm_rf remote_path end
    Application.put_env :eetoul, :git_path, path
    case SampleRemoteRepo.create path, remote_path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  test "`push`", meta do
    assert ManualCommands.exec("git ls-remote origin") == ""
    call = fn ->
      CLI.run_command meta.repo, ~W[specs-push --remote origin]
    end
    assert %{stderr: ""} = capture_io(call)
    expected_value =
      ManualCommands.exec("git show eetoul-spec --format=format:%H")
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.at(0)
    assert "#{expected_value}\trefs/heads/eetoul-spec\n" == ManualCommands.exec("git ls-remote origin")
  end
end
