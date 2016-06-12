defmodule Eetoul.Commands.AddTo do
  import ShortMaps
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "adds a step to the Eetoul spec"

  command do
    release :release
    reference :branch
    flag :merge
    flag :rebase
    string :message
  end

  validate "Arguments --merge and --rebase cannot both be specified." do
    !(args[:merge] && args[:rebase])
  end

  validate "Argument --message is required if neither --merge nor --rebase are specified." do
    !(!args[:message] && !args[:merge] && !args[:rebase])
  end

  validate "Argument --message is only allowed if neither --merge nor --rebase are specified." do
    !(args[:message] && (args[:merge] || args[:rebase]))
  end

  def run repo, args do
    {:ok, _} =
      RepoUtils.commit repo, "refs/heads/eetoul-spec", "added #{args.branch} to release \"#{args.release}\"",
    fn files ->
      Map.update! files, args.release, &(add_to_spec_file args, &1)
    end
    IO.puts "Added \"#{args.branch}\" to release \"#{args.release}\"."
  end

  defp add_to_spec_file args, file = ~m{content}a do
    new_line =
      case args do
        ~m{branch message}a -> "take #{branch} #{message}\n"
        %{branch: branch, merge: true} -> "take-merge #{branch}\n"
        %{branch: branch, rebase: true} -> "take-rebase #{branch}\n"
      end
    Map.put file, :content, content <> new_line
  end
end
