defmodule EetoulWriteCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.Utils
  alias Eetoul.CLI
  alias Eetoul.Test.SampleTreeRepo

  setup_all do
    Utils.seed
    :ok
  end

  setup do
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    case SampleTreeRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  test "`init`, `create` and `add-to`", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[init]
    end
    assert %{stdout: "Initialized the Eetoul spec branch.\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "", stderr: "The release \"first-release\" does not exist.\n"} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[create first-release first]
    end
    assert %{stdout: "Created release \"first-release\" based on \"first\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "checkout first\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[add-to first-release second --rebase]
    end
    assert %{stdout: "Added \"second\" to release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[add-to first-release third --message] ++ ["Third tag is here"]
    end
    assert %{stdout: "Added \"third\" to release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[add-to first-release fourth --merge]
    end
    assert %{stdout: "Added \"fourth\" to release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "checkout first\ntake-rebase second\ntake third Third tag is here\ntake-merge fourth\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[rename first-release second-release]
    end
    assert %{stdout: "Renamed \"first-release\" to \"second-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat second-release]
    end
    assert %{stdout: "checkout first\ntake-rebase second\ntake third Third tag is here\ntake-merge fourth\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "", stderr: "The release \"first-release\" does not exist.\n"} = capture_io(call)
  end

  test "`init`, `create` and `archive` and `unarchive`", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[init]
    end
    assert %{stdout: "Initialized the Eetoul spec branch.\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[create first-release first]
    end
    assert %{stdout: "Created release \"first-release\" based on \"first\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[archive first-release]
    end
    assert %{stdout: "Archived release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[acat first-release]
    end
    assert %{stdout: "checkout first\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "", stderr: "The release \"first-release\" does not exist.\n"} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[unarchive first-release]
    end
    assert %{stdout: "Unarchived release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "checkout first\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[acat first-release]
    end
    assert %{stdout: "", stderr: "The archived release \"first-release\" does not exist.\n"} = capture_io(call)
  end
end
