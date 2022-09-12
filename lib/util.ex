defmodule Banshee.Util do
  @doc """
  Calls a protocol function if the data implements the protocol, else
  returns a default value.
  """
  def proto(proto, mod, fun, [arg | _] = args, default) do
    case proto.impl_for(arg) do
      nil -> default
      _other -> apply(mod, fun, args)
    end
  end
end
