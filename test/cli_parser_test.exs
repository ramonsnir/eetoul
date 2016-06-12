defmodule EetoulCLIParserTest do
  use ExUnit.Case, async: true
  alias Eetoul.CLI
  alias Eetoul.CLI.ParseError
  alias Eetoul.Test.SampleSpecRepo

  setup_all do
    SampleSpecRepo.setup(&on_exit/1)
  end

  test "`edit <release>`", meta do
    assert %{release: "first-release"} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[edit first-release])
  end

  test "`edit <new-release>` fails", meta do
    assert_raise ParseError, "The release \"zeroth-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[edit zeroth-release]
    end
  end

  test "`edit <archived-release>` fails", meta do
    assert_raise ParseError, "The release \"ancient-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[edit ancient-release]
    end
  end

  test "`edit <release> --amend`", meta do
    assert %{release: "first-release", amend: true} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[edit first-release --amend])
  end

  test "`edit` fails", meta do
    assert_raise ParseError, "No release was specified.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[edit]
    end
  end

  test "`edit <release> arg` fails", meta do
    assert_raise ParseError, "Invalid arguments.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[edit first-release arg]
    end
  end

  test "`edit <release> --amend arg` fails", meta do
    assert_raise ParseError, "Invalid arguments.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[edit first-release --amend arg]
    end
  end

  test "`create <new-release> <branch>`", meta do
    assert %{release: "zeroth-release", base_branch: "first-branch"} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[create zeroth-release first-branch])
  end

  test "`create <new-release> <tag>`", meta do
    assert %{release: "zeroth-release", base_branch: "first-tag"} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[create zeroth-release first-tag])
  end

  test "`create <new-release> <wrong-branch>` fails", meta do
    assert_raise ParseError, "The base branch \"zeroth-branch\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[create zeroth-release zeroth-branch]
    end
  end

  test "`create <existing-release> <branch>` fails", meta do
    assert_raise ParseError, "The release \"first-release\" already exists.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[create first-release first-branch]
    end
  end

  test "`create <existing-archived-release> <branch>` fails", meta do
    assert_raise ParseError, "The release \"ancient-release\" already exists.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[create ancient-release first-branch]
    end
  end

  test "`unarchive <archived-release>`", meta do
    assert %{archived_release: "ancient-release"} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[unarchive ancient-release])
  end

  test "`unarchive <release>` fails", meta do
    assert_raise ParseError, "The archived release \"first-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[unarchive first-release]
    end
  end

  test "`unarchive <new-release>` fails", meta do
    assert_raise ParseError, "The archived release \"zeroth-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[unarchive zeroth-release]
    end
  end

  test "`init`", meta do
    assert %{} == CLI.test_cli_argument_parser(meta.repo, ~W[init])
  end

  test "`specs-push`", meta do
    assert %{} == CLI.test_cli_argument_parser(meta.repo, ~W[specs-push])
  end

  test "`init <release>` fails", meta do
    assert_raise ParseError, "Invalid arguments starting with first-release.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[init first-release]
    end
  end

  test "`add-to <release> <branch> --message \"foo bar\"`", meta do
    assert %{release: "first-release", branch: "first-branch", message: "foo bar"} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[add-to first-release first-branch --message] ++ ["foo bar"])
  end

  test "`add-to <release> <branch> --merge`", meta do
    assert %{release: "first-release", branch: "first-branch", merge: true} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[add-to first-release first-branch --merge])
  end

  test "`add-to <release> <branch> --rebase`", meta do
    assert %{release: "first-release", branch: "first-branch", rebase: true} ==
      CLI.test_cli_argument_parser(meta.repo, ~W[add-to first-release first-branch --rebase])
  end

  test "`add-to <release> <branch>` fails", meta do
    assert_raise ParseError, "Argument --message is required if neither --merge nor --rebase are specified.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[add-to first-release first-branch]
    end
  end

  test "`add-to <release> <branch> --message` fails", meta do
    assert_raise ParseError, "Argument --message is only allowed if neither --merge nor --rebase are specified.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[add-to first-release first-branch --message first-branch --merge]
    end
  end

  test "`add-to <release> <branch> --rebase --merge` fails", meta do
    assert_raise ParseError, "Arguments --merge and --rebase cannot both be specified.", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[add-to first-release first-branch --rebase --merge]
    end
  end

  test "`notanop` fails with ParseError", meta do
    assert_raise ParseError, "Unknown command \"notanop\".", fn ->
      CLI.test_cli_argument_parser meta.repo, ~W[notanop]
    end
  end
end
