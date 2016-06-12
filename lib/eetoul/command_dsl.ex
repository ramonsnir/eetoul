defmodule Eetoul.CommandDSL do
  @doc ""
  defmacro __using__ _opts do
    quote do
      @behaviour Eetoul.Command

      import Eetoul.CommandDSL

      @before_compile Eetoul.CommandDSL

      @doc ""
      def name do
        get_module_cli_name __MODULE__
      end

      @validations []
    end
  end

  @doc ""
  defmacro __before_compile__(_env) do
    quote do
      @doc ""
      def validations do
        @validations
        |> Enum.reverse
      end
    end
  end

  @doc ""
  defmacro command do: block do
    quote do
      def arguments do
        var!(args) = []
        unquote block
        var!(args) |> Enum.reverse
      end
    end
  end

  @doc ""
  defmacro validate error_message, do: block do
    id = :"__validation_#{:random.uniform(10000)}"
    quote do
      def unquote(id)(args) do
        var!(args) = args
        unless unquote(block) do
          raise Eetoul.CLI.ParseError, message: unquote(error_message)
        end
      end

      @validations [unquote(id) | @validations]
    end
  end

  @doc ""
  def get_module_cli_name module do
    # in PascalCase
    command_name =
      module
    |> Atom.to_string
    |> String.split(".")
    |> Enum.reverse
    |> Enum.fetch!(0)
    # converting PascalCase to lisp-case
    Regex.replace(~r/([a-z])([A-Z])/, command_name,
                  "\\1-\\2", [global: true])
    |> String.downcase
  end

  @doc ""
  defmacro release arg_name do
    quote do
      var!(args) = [{:release, unquote(arg_name), :existing} | var!(args)]
    end
  end

  @doc ""
  defmacro new_release arg_name do
    quote do
      var!(args) = [{:release, unquote(arg_name), :new} | var!(args)]
    end
  end

  @doc ""
  defmacro archived_release arg_name do
    quote do
      var!(args) = [{:release, unquote(arg_name), :archived} | var!(args)]
    end
  end

  @doc ""
  defmacro reference arg_name do
    quote do
      var!(args) = [{:reference, unquote(arg_name)} | var!(args)]
    end
  end

  @doc ""
  defmacro flag arg_name do
    quote do
      var!(args) = case var!(args) do
                     [{:options, options} | rest] ->
                       [{:options, [{unquote(arg_name), :boolean} | options]} | rest]
                     rest -> [{:options, [{unquote(arg_name), :boolean}]} | rest]
                   end
    end
  end

  @doc ""
  defmacro string arg_name do
    quote do
      var!(args) = case var!(args) do
                     [{:options, options} | rest] ->
                       [{:options, [{unquote(arg_name), :string} | options]} | rest]
                     rest -> [{:options, [{unquote(arg_name), :string}]} | rest]
                   end
    end
  end
end
