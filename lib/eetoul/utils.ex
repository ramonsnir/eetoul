defmodule Eetoul.Utils do
  def seed do
    :random.seed(
      :erlang.phash2([node]),
      :erlang.monotonic_time,
      :erlang.unique_integer
    )
  end
end
