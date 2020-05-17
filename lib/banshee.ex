defmodule Banshee do
  @moduledoc """
  
  """
  @compile {:inline, select: 3, transform: 4}

  @type navigator :: atom | {atom, term} | {atom, atom, term}

  @doc "Selects data by an arbitrary list of navigators"
  @spec select(navigators :: [navigator], data :: term) :: [term]
  def select([], data), do: [data]
  def select([nav | navs], data), do: select(nav, navs, data)
  
  defp select(m, navs, data) when is_atom(m), do: m.select(navs, data)
  defp select({m, f}, n, d) when is_atom(m) and is_atom(f), do: apply(m, f, [n, d])
  defp select({m, a}, n, d) when is_atom(m), do: m.select(a, n, d)
  defp select({m, f, a}, n, d) when is_atom(m) and is_atom(f), do: apply(m, f, [a, n, d])

  @doc "Transforms data with a function and an arbitrary list of navigators"
  @spec transform(navigators :: [navigator], data :: term, transform :: (term -> term)) :: term
  def transform([], data, xf), do: xf.(data)
  def transform([nav | navs], data, xf), do: transform(nav, navs, data, xf)

  defp transform(m, navs, data, xf) when is_atom(m), do: m.select(navs, data, xf)
  defp transform({m, f}, n, d, x) when is_atom(m) and is_atom(f), do: apply(m, f, [n, d, x])
  defp transform({m, a}, n, d, x) when is_atom(m), do: m.transform(a, n, d, x)
  defp transform({m, f, a}, n, d, x) when is_atom(m) and is_atom(f), do: apply(m, f, [a, n, d, x])

  defmodule Navigator do
    @moduledoc "A behaviour abstracting over navigation to query and update data"
    @callback select([Banshee.navigator], data :: term) :: [term]
    @callback select(arg :: term, [Banshee.navigator], data :: term) :: [term]
    @callback transform([Banshee.navigator], data :: term, transform :: (term -> term)) :: [term]
    @callback transform(arg :: term, [Banshee.navigator], data :: term, transform :: (term, term -> term)) :: [term]
    @optional_callbacks select: 2, transform: 3
  end

end
