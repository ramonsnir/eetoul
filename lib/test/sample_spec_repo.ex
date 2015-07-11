defmodule Eetoul.Test.SampleSpecRepo do
  use Geef
  alias Eetoul.RepoUtils

  @doc ""
  def create path do
    :ok = File.mkdir path
    {:ok, repo} = Repository.init path, true

    {:ok, commit} = RepoUtils.make_commit(repo, "Eetoul Spec",
                                          %{"first-release" => "checkout first-branch\ntake first-branch\n",
                                            "second-release" => "checkout first-release\n",
                                            ".archive/ancient-release" => "checkout no-commit\n"})
    {:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", commit

    {:ok, commit} = RepoUtils.make_commit(repo, "Code Branch 1",
                                          %{"greeting" => "Hello world!"})
    {:ok, _ref} = Reference.create repo, "refs/tags/first-tag", commit
    {:ok, commit} = RepoUtils.make_commit(repo, "Code Branch 2",
                                          %{"greeting" => "Hello, all!"},
                                          [commit])
    {:ok, _ref} = Reference.create repo, "refs/heads/first-branch", commit

    {:ok, repo}
  end
end
