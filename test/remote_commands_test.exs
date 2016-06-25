defmodule EetoulRemoteCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.Utils
  alias Eetoul.CLI
  alias Eetoul.ManualCommands
  alias Eetoul.RecordedConflictResolutions
  alias Eetoul.Test.SampleRemoteRepo

  setup_all do
    Utils.seed
    :ok
  end

  setup do
    path = "tmp-#{__MODULE__}-#{:rand.uniform 1000000}"
    remote_path = "tmp-#{__MODULE__}-remote-#{:rand.uniform 1000000}"
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
    assert ManualCommands.exec!("git ls-remote origin") == ""
    call = fn ->
      CLI.run_command meta.repo, ~W[specs-push --remote origin]
    end
    assert %{stderr: ""} = capture_io(call)
    expected_eetoul_spec = get_commit_id_from_reference "eetoul-spec"
    expected_eetoul_rcr = get_commit_id_from_reference RecordedConflictResolutions.rcr_branch
    expected_value =
      [
        "#{expected_eetoul_spec}\trefs/heads/eetoul-spec",
        "#{expected_eetoul_rcr}\t#{RecordedConflictResolutions.rcr_reference}",
      ]
    |> Enum.sort
    found_value =
      ManualCommands.exec!("git ls-remote origin")
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.sort
    assert expected_value == found_value
  end

  defp get_commit_id_from_reference ref do
    ManualCommands.exec!("git show #{ref} --format=format:%H")
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.at(0)
  end
end
