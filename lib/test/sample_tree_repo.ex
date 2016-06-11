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
  @lint {Credo.Check.Refactor.ABCSize, false}
  def create path do
    :ok = File.mkdir path
    {:ok, repo} = Repository.init path, true

    {:ok, first_commit} =
      RepoUtils.make_commit(repo, "First",
                            %{"greeting" => "Hello",
                              "target" => "world"})
    {:ok, second_commit} =
      RepoUtils.make_commit(repo, "Second",
                            %{"greeting" => "Hello",
                              "target" => "world",
                              "dist/total" => "Hello, world!"},
                            [first_commit])
    {:ok, third_commit} =
      RepoUtils.make_commit(repo, "Third",
                            %{"greeting" => "Bonjour",
                              "target" => "monde"},
                            [first_commit])
    {:ok, fourth_commit} =
      RepoUtils.make_commit(repo, "Fourth",
                            %{"greeting" => "Bonjour",
                              "target" => "monde",
                              "dist/total" => "Bonjour, monde!"},
                            [second_commit, third_commit])
    {:ok, fifth_commit} =
      RepoUtils.make_commit(repo, "Fifth",
                            %{"greeting" => "Ciao",
                              "target" => "mundo"},
                            [third_commit])
    {:ok, expected_test_release_take} =
      RepoUtils.make_commit(repo, "Fourth, squashed",
                            %{"greeting" => "Bonjour",
                              "target" => "monde",
                              "dist/total" => "Bonjour, monde!"},
                            [first_commit])
    {:ok, expected_test_release_merge} =
      RepoUtils.make_commit(repo, "Merged third",
                            %{"greeting" => "Bonjour",
                              "target" => "monde",
                              "dist/total" => "Hello, world!"},
                            [second_commit, third_commit])

    {:ok, _ref} = Reference.create repo, "refs/tags/first", first_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/second", second_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/third", third_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/fourth", fourth_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/fifth", fifth_commit
    {:ok, _ref} = Reference.create repo, "refs/heads/master", fourth_commit
    {:ok, _ref} = Reference.create repo, "refs/heads/side-branch", fifth_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/expected-test-release-take", expected_test_release_take
    {:ok, _ref} = Reference.create repo, "refs/tags/expected-test-release-merge", expected_test_release_merge

    test_release_checkout = "checkout first\n"
    test_release_take = """
checkout first
take fourth Fourth, squashed
"""
    test_release_merge = """
checkout first
take-merge second
take-merge third
"""
    test_release_multiple = """
checkout first
take fourth Fourth, squashed
take third Third
take-merge fifth
"""

    {:ok, spec_commit} = RepoUtils.make_commit(repo, "",
                                               %{"test-release-checkout" => test_release_checkout,
                                                 "test-release-take" => test_release_take,
                                                 "test-release-merge" => test_release_merge,
                                                 "test-release-multiple" => test_release_multiple},
                                               [])
    {:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", spec_commit

    {:ok, repo}
  end
end
