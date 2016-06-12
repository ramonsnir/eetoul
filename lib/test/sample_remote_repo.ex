defmodule Eetoul.Test.SampleRemoteRepo do
  use Geef
  alias Eetoul.ManualCommands
  alias Eetoul.RecordedConflictResolutions
  alias Eetoul.RepoUtils

  @doc ""
  def create path, remote_path do
    {:ok, _remote_repo} = create_remote remote_path
    :ok = File.mkdir path
    {:ok, repo} = Repository.init path, true
    {:ok, commit} = RepoUtils.make_commit(repo, "Eetoul Spec",
                                          %{"first-release" => "checkout first-branch\ntake first-branch\n",
                                            "second-release" => "checkout first-release\n",
                                            ".archive/ancient-release" => "checkout no-commit\n"})
    {:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", commit
    {:ok, commit} = RepoUtils.make_commit(repo, "Eetoul RCR", %{})
    {:ok, _ref} = Reference.create repo, RecordedConflictResolutions.rcr_reference, commit
    ManualCommands.exec! "git remote add origin \"#{File.cwd!}/#{remote_path}\""
    {:ok, repo}
  end

  defp create_remote path do
    :ok = File.mkdir path
    Repository.init path, true
  end
end
