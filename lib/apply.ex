defmodule Banshee.Apply do
  @doc """
  A Navigator that applies a function to the current item

  Param required, one of:
  * 1-arity function
  * module name on which to call `select/1` or `transform/1` depending on operation
  * {module_name, function_name}, as above, but with a custom function name
  * {module_name, function_name, arg}, as above, but provides an
    additional argument to the function call in first position (so needs a `/2`)
  """

  @behaviour Banshee.Navigator

  @type mf :: {module :: atom, fun :: atom}
  @type param :: (term -> term) | mf | mfa

  import Banshee, only: [select: 2, transform: 3]

  def select(fun, navs, data) when is_function(fun, 1),
    do: select(navs, fun.(data))

  def select({m, f}, n, d) when is_atom(m) and is_atom(f),
    do: select(n, apply(m, f, [d]))

  def select({m, f, a}, n, d) when is_atom(m) and is_atom(f),
    do: select(n, apply(m, f, [a, d]))

  def transform(f, n, d, x) when is_function(f, 1), do: transform(n, f.(d), x)

  def transform({m, f}, n, d, x) when is_atom(m) and is_atom(f) do
    transform(n, apply(m, f, [d]), x)
  end

  def transform({m, f, a}, n, d, x) when is_atom(m) and is_atom(f) do
    transform(n, apply(m, f, [a, d]), x)
  end
end
