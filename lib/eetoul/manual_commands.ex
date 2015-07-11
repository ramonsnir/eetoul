defmodule Eetoul.ManualCommands do
  @doc ""
  def exec command do
    git_path = Application.get_env :eetoul, :git_path
    :os.cmd('cd #{git_path} && #{command}')
    |> List.to_string
  end
end
