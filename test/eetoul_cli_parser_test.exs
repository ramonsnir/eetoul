defmodule EetoulCLIParserTest do
  use ExUnit.Case
	use Geef
	alias Eetoul.CLI
	alias Eetoul.CLI.ParseError
	alias Eetoul.Test.SampleSpecRepo

	setup_all do
		{a, b, c} = :erlang.now
		:random.seed a, b, c
		path = "tmp-#{:random.uniform 1000000}"
		on_exit fn -> File.rm_rf path end
		case SampleSpecRepo.create path do
			{:ok, repo} ->
				{:ok, repo: repo}
			e -> e
		end
	end

	test "read_spec utility method", meta do
		assert CLI.read_spec(meta[:repo], "first-release") ==
			{:ok, ""}
		assert CLI.read_spec(meta[:repo], "first-branch") ==
			{:error, "The path 'first-branch' does not exist in the given tree"}
	end
	
  test "`edit <release>`", meta do
    assert CLI.test_cli_argument_parser(meta[:repo], ["edit", "first-release"]) ==
			%{release: "first-release"}
  end

  test "`edit <wrong-release>` fails", meta do
		assert_raise ParseError, "the release \"zeroth-release\" does not exist", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit", "zeroth-release"]
		end
  end

  test "`edit <release> --amend`", meta do
    assert CLI.test_cli_argument_parser(meta[:repo], ["edit", "first-release", "--amend"]) ==
			%{release: "first-release", amend: true}
  end

  test "`edit` fails", meta do
    assert_raise ParseError, "no release was specified", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit"]
		end
  end

  test "`edit <release> arg` fails", meta do
    assert_raise ParseError, "invalid arguments", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit", "first-release", "arg"]
		end
  end

  test "`edit <release> --amend arg` fails", meta do
    assert_raise ParseError, "invalid arguments", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["edit", "first-release", "--amend", "arg"]
		end
  end

	test "`create <new-release> <branch>`", meta do
		assert CLI.test_cli_argument_parser(meta[:repo], ["create", "zeroth-release", "first-branch"]) ==
			%{release: "zeroth-release", base_branch: "refs/heads/first-branch"}
	end

	test "`create <new-release> <tag>`", meta do
		assert CLI.test_cli_argument_parser(meta[:repo], ["create", "zeroth-release", "first-tag"]) ==
			%{release: "zeroth-release", base_branch: "refs/tags/first-tag"}
	end

  test "`create <new-release> <wrong-branch>` fails", meta do
		assert_raise ParseError, "the base_branch \"zeroth-branch\" does not exist", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["create", "zeroth-release", "zeroth-branch"]
		end
  end

  test "`create <existing-release> <branch>` fails", meta do
		assert_raise ParseError, "the release \"first-release\" already exists", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["create", "first-release", "first-branch"]
		end
  end

	test "`init`", meta do
		assert CLI.test_cli_argument_parser(meta[:repo], ["init"]) ==
			%{}
	end

	test "`specs-push`", meta do
		assert CLI.test_cli_argument_parser(meta[:repo], ["specs-push"]) ==
			%{}
	end

	test "`init <release>` fails", meta do
		assert_raise ParseError, "invalid arguments starting with first-release", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["init", "first-release"]
		end
	end

	test "`add-to <release> <branch> --squash --message \"foo bar\"`", meta do
		assert CLI.test_cli_argument_parser(meta[:repo], ["add-to", "first-release", "first-branch", "--squash", "--message", "foo bar"]) ==
			%{release: "first-release", branch: "refs/heads/first-branch", squash: true, message: "foo bar"}
	end

	test "`add-to <release> <branch> --squash` fails", meta do
		assert_raise ParseError, "--message is requires if --squash or --merge are specified", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["add-to", "first-release", "first-branch", "--squash"]
		end
	end

	test "`add-to <release> <branch> --squash --merge` fails", meta do
		assert_raise ParseError, "--squash and --merge cannot both be specified", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["add-to", "first-release", "first-branch", "--squash", "--merge"]
		end
	end

  test "`noop` fails with ParseError", meta do
    assert_raise ParseError, "unknown command noop", fn ->
			CLI.test_cli_argument_parser meta[:repo], ["noop"]
		end
  end
end
