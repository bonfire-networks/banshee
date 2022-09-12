defmodule Banshee.If do
  @doc """
  A Navigator that requires the current item to pass a test.

  Param required, one of:
  * 1-arity function
  * {module_name, function_name}, to call, function must be `/1`
  * {module_name, function_name, arg}, as above, but provides an
    additional argument to the function call in first position (so needs a `/2`)
  """

  @behaviour Banshee.Navigator

  @type mf :: {module :: atom, fun :: atom}
  @type param :: (term -> term) | mf | mfa

  import Banshee, only: [select: 2, transform: 3]

  def select(fun, navs, data) when is_function(fun, 1) do
    if fun.(data), do: select(navs, data), else: []
  end

  def select({m, f}, n, d) when is_atom(m) and is_atom(f) do
    if apply(m, f, [d]), do: select(n, d), else: []
  end

  def select({m, f, a}, n, d) when is_atom(m) and is_atom(f) do
    if apply(m, f, [a, d]), do: select(n, d), else: []
  end

  def transform(f, n, d, x) when is_function(f, 1) do
    if f.(d), do: transform(n, d, x), else: d
  end

  def transform({m, f}, n, d, x) when is_atom(m) and is_atom(f) do
    if apply(m, f, [d]), do: transform(n, d, x), else: d
  end

  def transform({m, f, a}, n, d, x) when is_atom(m) and is_atom(f) do
    if apply(m, f, [a, d]), do: transform(n, d, x), else: d
  end
end
