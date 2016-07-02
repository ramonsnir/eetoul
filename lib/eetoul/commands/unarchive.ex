defmodule Eetoul.Commands.Unarchive do
  use Eetoul.CommandDSL
  alias Eetoul.RecordedConflictResolutions
  alias Eetoul.RepoUtils

  def description, do: "unarchives the Eetoul spec"

  command do
    archived_release :archived_release
    flag :force
  end

  def run repo, args do
    {:ok, _} =
      RepoUtils.commit repo, "refs/heads/eetoul-spec", "unarchived release \"#{args.archived_release}\"", fn files ->
      {file, files} = Map.pop files, ".archive/#{args.archived_release}"
      Map.put files, args.archived_release, file
    end
    unarchive_rcr repo, args
    IO.puts "Unarchived release \"#{args.archived_release}\"."
  end

  defp unarchive_rcr repo, args do
    relevant_rcr_present? =
      case RepoUtils.read_commit(repo, RecordedConflictResolutions.rcr_reference) do
        {:ok, files} ->
          Enum.any? files, fn {path, _} -> String.starts_with? path, ".archive/#{args.archived_release}/" end
        _ -> false
      end
    if relevant_rcr_present? do
      {:ok, _} =
        RepoUtils.commit repo,
        RecordedConflictResolutions.rcr_reference,
        "unarchived release \"#{args.archived_release}\"",
        &(unarchive_files &1, args.archived_release)
    end
  end

  defp unarchive_files files, release do
    Enum.map files, fn o = {path, content} ->
      if String.starts_with?(path, ".archive/#{release}/") do
        {String.trim_leading(path, ".archive/"), content}
      else
        o
      end
    end
  end
end
