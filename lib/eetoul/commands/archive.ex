defmodule Eetoul.Commands.Archive do
  use Eetoul.CommandDSL
  alias Eetoul.RecordedConflictResolutions
  alias Eetoul.RepoUtils

  def description, do: "archives the Eetoul integration branch"

  command do
    release :release
    flag :force
  end

  def run repo, args do
    {:ok, _} = RepoUtils.commit repo, "refs/heads/eetoul-spec", "archived release \"#{args.release}\"", fn files ->
      {file, files} = Map.pop files, args.release
      Map.put files, ".archive/#{args.release}", file
    end
    archive_rcr repo, args
    IO.puts "Archived release \"#{args.release}\"."
  end

  defp archive_rcr repo, args do
    relevant_rcr_present? =
      case RepoUtils.read_commit(repo, RecordedConflictResolutions.rcr_reference) do
        {:ok, files} ->
          Enum.any? files, fn {path, _} -> String.starts_with? path, "#{args.release}/" end
        _ -> false
      end
    if relevant_rcr_present? do
      {:ok, _} =
        RepoUtils.commit repo,
        RecordedConflictResolutions.rcr_reference,
        "archived release \"#{args.release}\"",
        &(archive_files &1, args.release)
    end
  end

  defp archive_files files, release do
    Enum.map files, fn o = {path, content} ->
      if String.starts_with?(path, "#{release}/") do
        {".archive/#{path}", content}
      else
        o
      end
    end
  end
end
