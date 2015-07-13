defmodule EetoulWriteCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.CLI
  alias Eetoul.Test.SampleTreeRepo

  setup_all do
    {a, b, c} = :erlang.timestamp
    :random.seed a, b, c
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
      CLI.run_command meta[:repo], ["init"]
    end
    assert %{stdout: "Initialized the Eetoul spec branch.\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "first-release"]
    end
    assert %{stdout: "", stderr: "The release \"first-release\" does not exist.\n"} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["create", "first-release", "first"]
    end
    assert %{stdout: "Created release \"first-release\" based on \"first\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "first-release"]
    end
    assert %{stdout: "checkout first\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["add-to", "first-release", "second"]
    end
    assert %{stdout: "Added \"second\" to release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["add-to", "first-release", "third", "--squash", "--message", "Third tag is here"]
    end
    assert %{stdout: "Added \"third\" to release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["add-to", "first-release", "fourth", "--merge"]
    end
    assert %{stdout: "Added \"fourth\" to release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "first-release"]
    end
    assert %{stdout: "checkout first\ntake second\ntake-squash third Third tag is here\ntake-merge fourth\n", stderr: ""} = capture_io(call)
  end

  test "`init`, `create` and `archive` and `unarchive`", meta do
    call = fn ->
      CLI.run_command meta[:repo], ["init"]
    end
    assert %{stdout: "Initialized the Eetoul spec branch.\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["create", "first-release", "first"]
    end
    assert %{stdout: "Created release \"first-release\" based on \"first\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["archive", "first-release"]
    end
    assert %{stdout: "Archived release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["acat", "first-release"]
    end
    assert %{stdout: "checkout first\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "first-release"]
    end
    assert %{stdout: "", stderr: "The release \"first-release\" does not exist.\n"} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["unarchive", "first-release"]
    end
    assert %{stdout: "Unarchived release \"first-release\".\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["cat", "first-release"]
    end
    assert %{stdout: "checkout first\n", stderr: ""} = capture_io(call)
    call = fn ->
      CLI.run_command meta[:repo], ["acat", "first-release"]
    end
    assert %{stdout: "", stderr: "The archived release \"first-release\" does not exist.\n"} = capture_io(call)
  end
end
