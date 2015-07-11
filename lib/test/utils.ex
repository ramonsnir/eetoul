defmodule Eetoul.Test.Utils do
  import ExUnit.CaptureIO

  @doc ""
  def capture_io fun do
    {:ok, result} = Agent.start_link fn -> %{} end
    save = fn name, value ->
      Agent.update result, &(Map.put &1, name, value)
    end
    save.(:stderr, capture_io(:stderr, fn ->
          save.(:stdout, capture_io(:stdio, fn ->
                value = fun.()
                save.(:value, value)
                value
              end))
        end))
    Agent.get result, &(&1)
  end
end
