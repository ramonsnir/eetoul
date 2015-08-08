defmodule Eetoul.Test.SampleTreeRepo do
  @moduledoc """

  Creates a repo with a basic graph structure, for basic testing of `make`.

    First
      |\
      | ---
      |    \
      |     \
    Second   Third
      |      /|
      |  ---  |
      | /     |
      |/      |
    Fourth   Fifth

  """

  use Geef
  alias Eetoul.RepoUtils

  @doc ""
  def create path do
    :ok = File.mkdir path
    {:ok, repo} = Repository.init path, true

    {:ok, first_commit} = RepoUtils.make_commit(repo, "First",
                                                %{"greeting" => "Hello",
                                                  "target" => "world"})
    {:ok, second_commit} = RepoUtils.make_commit(repo, "Second",
                                                 %{"greeting" => "Hello",
                                                   "target" => "world",
                                                   "dist/total" => "Hello, world!"},
                                                 [first_commit])
    {:ok, third_commit} = RepoUtils.make_commit(repo, "Third",
                                                %{"greeting" => "Bonjour",
                                                  "target" => "monde"},
                                                [first_commit])
    {:ok, fourth_commit} = RepoUtils.make_commit(repo, "Fourth",
                                                 %{"greeting" => "Bonjour",
                                                   "target" => "monde",
                                                   "dist/total" => "Bonjour, monde!"},
                                                 [second_commit, third_commit])
    {:ok, fifth_commit} = RepoUtils.make_commit(repo, "Fifth",
                                                %{"greeting" => "Ciao",
                                                  "target" => "mundo"},
                                                [third_commit])

    {:ok, _ref} = Reference.create repo, "refs/tags/first", first_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/second", second_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/third", third_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/fourth", fourth_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/fifth", fifth_commit
    {:ok, _ref} = Reference.create repo, "refs/heads/master", fourth_commit
    {:ok, _ref} = Reference.create repo, "refs/heads/side-branch", fifth_commit

    test_release_a = "checkout first\n"
    test_release_b = """
checkout first
take-squash fourth Fourth, squashed
take-squash third Third
take-squash fifth
"""
    {:ok, spec_commit} = RepoUtils.make_commit(repo, "",
                                               %{"test-release-a" => test_release_a,
                                                 "test-release-b" => test_release_b},
                                               [])
    {:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", spec_commit

    {:ok, repo}
  end
end
