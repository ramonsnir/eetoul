defmodule EetoulBuildTest do
  use ExUnit.Case
  use Geef
  alias Eetoul.Utils
  alias Eetoul.Build
  alias Eetoul.Build.ReferenceError
  alias Eetoul.Build.TakeError
  alias Eetoul.Test.SampleTreeRepo

  setup_all do
    Utils.seed
    path = "tmp-#{__MODULE__}-#{:rand.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    Application.put_env :eetoul, :git_path, path
    case SampleTreeRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end

  setup do
    Utils.seed
    :ok
  end

  test "build non-existent spec", meta do
    assert_raise ReferenceError, "Eetoul spec \"no-release\" was not found.", fn ->
      Build.build meta.repo, "no-release"
    end
  end

  test "build a single checkout", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/first"
    assert :ok = Build.build(meta.repo, "test-release-checkout",
                             target_name: "refs/heads/test-release-checkout", output: :quiet)
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-checkout"
    assert expected == found
  end

  test "build a take", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/expected-test-release-take"
    assert :ok = Build.build(meta.repo, "test-release-take",
                             target_name: "refs/heads/test-release-take", output: :quiet)
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-take"
    assert expected == found
  end

  test "build a merge", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/expected-test-release-merge"
    assert :ok = Build.build(meta.repo, "test-release-merge",
                             target_name: "refs/heads/test-release-merge", output: :quiet)
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-merge"
    assert expected == found
  end

  test "build WITH a recorded conflict resolution", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/expected-test-release-conflict"
    assert :ok = Build.build(meta.repo, "test-release-conflict",
                             target_name: "refs/heads/test-release-conflict", output: :quiet)
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-conflict"
    assert expected == found
  end

  test "build withOUT a recorded conflict resolution", meta do
    assert_raise TakeError, "Could not take branch \"fifth\".", fn ->
      Build.build(meta.repo, "test-release-conflict-failure",
                  output: :quiet)
    end
  end
end
