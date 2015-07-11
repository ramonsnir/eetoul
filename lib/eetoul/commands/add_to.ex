defmodule Eetoul.Commands.AddTo do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  command do
    release :release
    reference :branch
    flag :squash
    flag :merge
    string :message
  end

  validate "Arguments --squash and --merge cannot both be specified." do
    !(args[:squash] && args[:merge])
  end

  validate "Argument --message is required if --squash is specified." do
    !(args[:squash] && !args[:message])
  end

  validate "Argument --message is only allowed if --squash is specified." do
    !(!args[:squash] && args[:message])
  end

  def run repo, args do
    Error.m do
      _commit <- RepoUtils.commit repo, "refs/heads/eetoul-spec", "added #{args[:branch]} to release \"#{args[:release]}\"", fn files ->
        files = Map.update! files, args[:release], fn file = %{content: value} ->
          new_line =
            case args do
              %{branch: branch, squash: true, message: message} -> "take-squash #{branch} #{message}\n"
              %{branch: branch, merge: true} -> "take-merge #{branch}\n"
              %{branch: branch} -> "take #{branch}\n"
            end
          Map.put file, :content, value <> new_line
        end
        {:ok, files}
      end
      _ok <- {IO.puts("Added \"#{args[:branch]}\" to release \"#{args[:release]}\"."), nil}
      return nil
    end
  end
end
