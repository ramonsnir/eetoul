defmodule EetoulWriteCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.Utils
  alias Eetoul.CLI
  alias Eetoul.RecordedConflictResolutions
  alias Eetoul.RepoUtils
  alias Eetoul.Test.SampleTreeRepo

  setup_all do
    Utils.seed
    :ok
  end

  setup do
    path = "tmp-#{__MODULE__}-#{:rand.uniform 1000000}"
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
    stdout = "checkout first\ntake-rebase second\ntake third Third tag is here\ntake-merge fourth\n"
    assert %{stdout: ^stdout, stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[rename first-release second-release]
    end
    assert %{stdout: "Renamed \"first-release\" to \"second-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta.repo, ~W[cat second-release]
    end
    stdout = "checkout first\ntake-rebase second\ntake third Third tag is here\ntake-merge fourth\n"
    assert %{stdout: ^stdout, stderr: ""} = capture_io(call)
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

  test "`archive` and `unarchive`", meta do
    RepoUtils.commit meta.repo, "refs/heads/eetoul-spec", "prep", fn files ->
      files
      |> Map.put("first-release", "first")
      |> Map.put("second-release", "second")
    end
    RepoUtils.commit meta.repo, RecordedConflictResolutions.rcr_reference, "prep", fn files ->
      files
      |> Map.put("first-release/file.a", "hello world")
      |> Map.put("first-release/file.b", "bye world")
      |> Map.put("second-release/file.c", "see you world")
    end

    capture_io fn ->
      CLI.run_command meta.repo, ~W[archive first-release]
    end
    {:ok, files} = RepoUtils.read_commit(meta.repo, "refs/heads/eetoul-spec")
    {:ok, rcr_files} = RepoUtils.read_commit(meta.repo, RecordedConflictResolutions.rcr_reference)
    assert files["first-release"] == nil
    assert files[".archive/first-release"] == "first"
    assert files["second-release"] == "second"
    assert files[".archive/second-release"] == nil
    assert rcr_files["first-release/file.a"] == nil
    assert rcr_files[".archive/first-release/file.a"] == "hello world"
    assert rcr_files["first-release/file.b"] == nil
    assert rcr_files[".archive/first-release/file.b"] == "bye world"
    assert rcr_files["second-release/file.c"] == "see you world"
    assert rcr_files[".archive/second-release/file.c"] == nil

    capture_io fn ->
      CLI.run_command meta.repo, ~W[unarchive first-release]
    end
    {:ok, files} = RepoUtils.read_commit(meta.repo, "refs/heads/eetoul-spec")
    {:ok, rcr_files} = RepoUtils.read_commit(meta.repo, RecordedConflictResolutions.rcr_reference)
    assert files["first-release"] == "first"
    assert files[".archive/first-release"] == nil
    assert files["second-release"] == "second"
    assert files[".archive/second-release"] == nil
    assert rcr_files["first-release/file.a"] == "hello world"
    assert rcr_files[".archive/first-release/file.a"] == nil
    assert rcr_files["first-release/file.b"] == "bye world"
    assert rcr_files[".archive/first-release/file.b"] == nil
    assert rcr_files["second-release/file.c"] == "see you world"
    assert rcr_files[".archive/second-release/file.c"] == nil
  end
end
