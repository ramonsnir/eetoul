defmodule Eetoul.RecordedConflictResolutions do
  use Geef
  alias Eetoul.RepoUtils
  require Monad.Error, as: Error

  @doc ""
  def reapply_recorded_resolutions repo, rcr_key, ref, base_commit, ref_commit do
    recorded_resolution_path = "#{rcr_key}/#{ref}/#{Base.encode16 base_commit}/#{Base.encode16 ref_commit}"
    Error.m do
      commit_id <- RepoUtils.read_file repo, rcr_reference, recorded_resolution_path
      _commit <- Commit.lookup repo, commit_id # verifying that commit is available in ODB
      return commit_id
    end
  end

  @doc ""
  def rcr_branch, do: "eetoul-recorded-conflict-resolutions"

  @doc ""
  def rcr_reference, do: "refs/heads/#{rcr_branch}"
end
