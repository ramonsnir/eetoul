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
      |      /
      |  ---
      | /
      |/
    Sixth

  """

  use Geef
  alias Eetoul.RecordedConflictResolutions
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
                              "target" => "continent",
                              "dist/total" => "Bonjour, continent!"},
                            [second_commit, third_commit])
    {:ok, fifth_commit} =
      RepoUtils.make_commit(repo, "Fifth",
                            %{"greeting" => "Ciao",
                              "target" => "mundo"},
                            [third_commit])
    {:ok, sixth_commit} =
      RepoUtils.make_commit(repo, "Sixth",
                            %{"greeting" => "Ciao",
                              "target" => "mundo",
                              "dist/total" => "Ciao, mundo!"},
                            [fourth_commit, fifth_commit])

    {:ok, expected_test_release_take} =
      RepoUtils.make_commit(repo, "Fourth, squashed",
                            %{"greeting" => "Bonjour",
                              "target" => "continent",
                              "dist/total" => "Bonjour, continent!"},
                            [first_commit])

    {:ok, expected_test_release_merge_step_a} =
      RepoUtils.make_commit(repo, "Merged second",
                            %{"greeting" => "Hello",
                              "target" => "world",
                              "dist/total" => "Hello, world!"},
                            [first_commit, second_commit])
    {:ok, expected_test_release_merge} =
      RepoUtils.make_commit(repo, "Merged third",
                            %{"greeting" => "Bonjour",
                              "target" => "monde",
                              "dist/total" => "Hello, world!"},
                            [expected_test_release_merge_step_a, third_commit])

    {:ok, expected_test_release_conflict_step_a} =
      RepoUtils.make_commit(repo, "Merged fourth",
                            %{"greeting" => "Bonjour",
                              "target" => "continent",
                              "dist/total" => "Bonjour, continent!"},
                            [first_commit, fourth_commit])
    {:ok, expected_test_release_conflict} =
      RepoUtils.make_commit(repo, "Merged fifth",
                            %{"greeting" => "Ciao",
                              "target" => "mundo",
                              "dist/total" => "Ciao, mundo!"},
                            [expected_test_release_conflict_step_a, fifth_commit])

    {:ok, _ref} = Reference.create repo, "refs/tags/first", first_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/second", second_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/third", third_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/fourth", fourth_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/fifth", fifth_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/sixth", sixth_commit
    {:ok, _ref} = Reference.create repo, "refs/heads/master", fourth_commit
    {:ok, _ref} = Reference.create repo, "refs/heads/side-branch", fifth_commit
    {:ok, _ref} = Reference.create repo, "refs/tags/expected-test-release-take", expected_test_release_take
    {:ok, _ref} = Reference.create repo, "refs/tags/expected-test-release-merge", expected_test_release_merge
    {:ok, _ref} = Reference.create repo, "refs/tags/expected-test-release-conflict", expected_test_release_conflict

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
    test_release_conflict = """
checkout first
take-merge fourth
take-merge fifth
"""
    test_release_multiple = """
checkout first
take fourth Fourth, squashed
take third Third
take-merge fifth
"""

    {:ok, spec_commit} = RepoUtils.make_commit(
      repo, "",
      %{
        "test-release-checkout" => test_release_checkout,
        "test-release-take" => test_release_take,
        "test-release-merge" => test_release_merge,
        "test-release-conflict" => test_release_conflict,
        "test-release-conflict-failure" => test_release_conflict,
        "test-release-multiple" => test_release_multiple,
      },
      [])
    {:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", spec_commit

    conflict_fifth_key =
      "test-release-conflict/fifth/" <>
    "#{Base.encode16 expected_test_release_conflict_step_a}/#{Base.encode16 fifth_commit}"
    {:ok, rcr_commit} = RepoUtils.make_commit(
      repo, "",
      %{
        conflict_fifth_key => expected_test_release_conflict,
      },
      [])
    {:ok, _ref} = Reference.create repo, RecordedConflictResolutions.rcr_reference, rcr_commit

    {:ok, repo}
  end
end
