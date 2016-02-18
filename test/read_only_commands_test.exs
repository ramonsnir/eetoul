defmodule EetoulReadOnlyCommandsTest do
  use ExUnit.Case
  import Eetoul.Test.Utils
  alias Eetoul.Utils
  alias Eetoul.CLI
  alias Eetoul.Test.SampleSpecRepo

  setup_all do
    Utils.seed
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    case SampleSpecRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  test "`help` prints full help", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[help]
    end
    expected_help = File.read! "HELP.txt"
    assert %{stdout: ^expected_help, stderr: ""} = capture_io(call)
  end

  test "`cat first-release` prints release spec", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[cat first-release]
    end
    assert %{stdout: "checkout first-branch\ntake first-branch\n", stderr: ""} = capture_io(call)
  end

  test "`cat no-release` prints error message", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[cat no-release]
    end
    assert %{stdout: "", stderr: "The release \"no-release\" does not exist.\n"} = capture_io(call)
  end

  test "`acat ancient-release` prints archived release spec", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[acat ancient-release]
    end
    assert %{stdout: "checkout no-commit\n", stderr: ""} = capture_io(call)
  end

  test "`acat no-ancient-release` prints error message", meta do
    call = fn ->
      CLI.run_command meta.repo, ~W[acat no-ancient-release]
    end
    assert %{stdout: "", stderr: "The archived release \"no-ancient-release\" does not exist.\n"} = capture_io(call)
  end
end
