defmodule EetoulCLIParserTest do
  use ExUnit.Case, async: true
  alias Eetoul.CLI
  alias Eetoul.CLI.ParseError
  alias Eetoul.Test.SampleSpecRepo

  setup_all do
    {a, b, c} = :erlang.timestamp
    :random.seed a, b, c
    path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf path
    on_exit fn -> File.rm_rf path end
    case SampleSpecRepo.create path do
      {:ok, repo} ->
        {:ok, repo: repo}
      e -> e
    end
  end
  
  test "`edit <release>`", meta do
    assert %{release: "first-release"} ==
      CLI.test_cli_argument_parser(meta[:repo], ["edit", "first-release"])
  end

  test "`edit <new-release>` fails", meta do
    assert_raise ParseError, "The release \"zeroth-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["edit", "zeroth-release"]
    end
  end

  test "`edit <archived-release>` fails", meta do
    assert_raise ParseError, "The release \"ancient-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["edit", "ancient-release"]
    end
  end

  test "`edit <release> --amend`", meta do
    assert %{release: "first-release", amend: true} ==
      CLI.test_cli_argument_parser(meta[:repo], ["edit", "first-release", "--amend"])
  end

  test "`edit` fails", meta do
    assert_raise ParseError, "No release was specified.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["edit"]
    end
  end

  test "`edit <release> arg` fails", meta do
    assert_raise ParseError, "Invalid arguments.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["edit", "first-release", "arg"]
    end
  end

  test "`edit <release> --amend arg` fails", meta do
    assert_raise ParseError, "Invalid arguments.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["edit", "first-release", "--amend", "arg"]
    end
  end

  test "`create <new-release> <branch>`", meta do
    assert %{release: "zeroth-release", base_branch: "first-branch"} ==
      CLI.test_cli_argument_parser(meta[:repo], ["create", "zeroth-release", "first-branch"])
  end

  test "`create <new-release> <tag>`", meta do
    assert %{release: "zeroth-release", base_branch: "first-tag"} ==
      CLI.test_cli_argument_parser(meta[:repo], ["create", "zeroth-release", "first-tag"])
  end

  test "`create <new-release> <wrong-branch>` fails", meta do
    assert_raise ParseError, "The base branch \"zeroth-branch\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["create", "zeroth-release", "zeroth-branch"]
    end
  end

  test "`create <existing-release> <branch>` fails", meta do
    assert_raise ParseError, "The release \"first-release\" already exists.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["create", "first-release", "first-branch"]
    end
  end

  test "`unarchive <archived-release>`", meta do
    assert %{archived_release: "ancient-release"} ==
      CLI.test_cli_argument_parser(meta[:repo], ["unarchive", "ancient-release"])
  end

  test "`unarchive <release>` fails", meta do
    assert_raise ParseError, "The archived release \"first-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["unarchive", "first-release"]
    end
  end

  test "`unarchive <new-release>` fails", meta do
    assert_raise ParseError, "The archived release \"zeroth-release\" does not exist.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["unarchive", "zeroth-release"]
    end
  end

  test "`init`", meta do
    assert %{} == CLI.test_cli_argument_parser(meta[:repo], ["init"])
  end

  test "`specs-push`", meta do
    assert %{} == CLI.test_cli_argument_parser(meta[:repo], ["specs-push"])
  end

  test "`init <release>` fails", meta do
    assert_raise ParseError, "Invalid arguments starting with first-release.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["init", "first-release"]
    end
  end

  test "`add-to <release> <branch> --squash --message \"foo bar\"`", meta do
    assert %{release: "first-release", branch: "first-branch", squash: true, message: "foo bar"} ==
      CLI.test_cli_argument_parser(meta[:repo], ["add-to", "first-release", "first-branch", "--squash", "--message", "foo bar"])
  end

  test "`add-to <release> <branch> --squash` fails", meta do
    assert_raise ParseError, "Argument --message is required if --squash is specified.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["add-to", "first-release", "first-branch", "--squash"]
    end
  end

  test "`add-to <release> <branch> --message` fails", meta do
    assert_raise ParseError, "Argument --message is only allowed if --squash is specified.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["add-to", "first-release", "first-branch", "--message", "first-branch"]
    end
  end

  test "`add-to <release> <branch> --squash --merge` fails", meta do
    assert_raise ParseError, "Arguments --squash and --merge cannot both be specified.", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["add-to", "first-release", "first-branch", "--squash", "--merge"]
    end
  end

  test "`noop` fails with ParseError", meta do
    assert_raise ParseError, "Unknown command \"noop\".", fn ->
      CLI.test_cli_argument_parser meta[:repo], ["noop"]
    end
  end
end
