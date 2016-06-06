defmodule EetoulBuildTest do
  use ExUnit.Case
  use Geef
  alias Eetoul.Utils
  alias Eetoul.Build
  alias Eetoul.Build.ReferenceError
  alias Eetoul.Test.SampleTreeRepo

  setup_all do
    Utils.seed
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
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
    assert :ok = Build.build(meta.repo, "test-release-checkout", "refs/heads/test-release-checkout")
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-checkout"
    assert expected == found
  end

  test "build a take", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/expected-test-release-take"
    assert :ok = Build.build(meta.repo, "test-release-take", "refs/heads/test-release-take")
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-take"
    assert expected == found
  end

  test "build a merge", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/fourth"
    assert :ok = Build.build(meta.repo, "test-release-merge", "refs/heads/test-release-merge")
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-merge"
    assert expected == found
  end
end
