defmodule EetoulCLIParserTest do
  use ExUnit.Case
	alias Eetoul.CLI
	alias Eetoul.CLI.ParseError

  test "`edit <release>`" do
    assert CLI.test_cli_argument_parser(["edit", "foo"]) ==
			%{release: "foo"}
  end

  test "`edit <release> --amend`" do
    assert CLI.test_cli_argument_parser(["edit", "foo", "--amend"]) ==
			%{release: "foo", amend: true}
  end

  test "`edit` fails" do
    assert_raise ParseError, "no release was specified", fn ->
			CLI.test_cli_argument_parser ["edit"]
		end
  end

  test "`edit <release> arg` fails" do
    assert_raise ParseError, "invalid arguments", fn ->
			CLI.test_cli_argument_parser ["edit", "foo", "arg"]
		end
  end

  test "`edit <release> --amend arg` fails" do
    assert_raise ParseError, "invalid arguments", fn ->
			CLI.test_cli_argument_parser ["edit", "foo", "--amend", "arg"]
		end
  end

  test "`noop` fails with ParseError" do
    assert_raise ParseError, "unknown command noop", fn ->
			CLI.test_cli_argument_parser ["noop"]
		end
  end
end
