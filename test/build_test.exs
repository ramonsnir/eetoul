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
    assert :ok = Build.build(meta.repo, "test-release-a", "refs/heads/test-release-a")
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-a"
    assert expected == found
  end

  test "build a take", meta do
    {:ok, %Reference{target: expected}} = Reference.lookup meta.repo, "refs/tags/second"
    assert :ok = Build.build(meta.repo, "test-release-b", "refs/heads/test-release-b")
    {:ok, %Reference{target: found}} = Reference.lookup meta.repo, "refs/heads/test-release-b"
    assert expected == found
  end
end
