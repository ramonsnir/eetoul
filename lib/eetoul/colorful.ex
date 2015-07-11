defmodule Eetoul.Colorful do
  @doc ""
  def string message, color do
    if Application.get_env(:eetoul, :interactive) do
      Colorful.string(message, color)
    else
      message
    end
  end
end
