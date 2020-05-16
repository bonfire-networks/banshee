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
    @callback select([Banshee.navigator], data :: term) :: [term]
    @callback select(arg :: term, [Banshee.navigator], data :: term) :: [term]
    @callback transform([Banshee.navigator], data :: term, transform :: (term -> term)) :: [term]
    @callback transform(arg :: term, [Banshee.navigator], data :: term, transform :: (term, term -> term)) :: [term]
    @optional_callbacks select: 2, transform: 3
  end

end
defmodule Banshee.All do

  @behaviour Banshee.Navigator
  
  def select(navs, data), do: Enum.flat_map(data, &Banshee.select(navs, &1))

  def select(_, navs, data), do: select(navs, data)

  def transform(navs, data, xf), do: Enum.map(data, &Banshee.transform(navs, &1, xf))

  def transform(_, navs, data, xf), do: transform(navs, data, xf)

end

defmodule Banshee.Apply do

  @behaviour Banshee.Navigator

  def select(fun, navs, data) when is_function(fun, 1), do: Banshee.select(navs, fun.(data))
  def select({m, f}, n, d) when is_atom(m) and is_atom(f), do: Banshee.select(n, apply(m, f, [d]))
  def select({m, f, a}, n, d) when is_atom(m) and is_atom(f), do: Banshee.select(n, apply(m, f, [a, d]))
  def select(_, _, _), do: []
  
  def transform(f, n, d, x) when is_function(f, 1), do: Banshee.transform(n, f.(d), x)
  def transform({m, f}, n, d, x) when is_atom(m) and is_atom(f), do: Banshee.transform(n, apply(m, f, [d]), x)
  def transform({m, f, a}, n, d, x) when is_atom(m) and is_atom(f), do: Banshee.transform(n, apply(m, f, [a, d]), x)

end

defmodule Banshee.Fork do

  @behaviour Banshee.Navigator

  def select(paths, navs, data) when is_list(paths), do: Enum.flat_map(paths, &sel(&1, navs, data))

  defp sel(path, navs, data) when is_list(path), do: Banshee.select(path ++ navs, data)
  defp sel(path, navs, data), do: Banshee.select([path | navs], data)

  def transform(paths, navs, data, xf), do: Enum.reduce(paths, data, &trans(&1, navs, &2, xf))

  def trans(p, n, d, x) when is_list(p), do: Banshee.transform(p ++ n, d, x)
  def trans(p, n, d, x), do: Banshee.transform([p | n], d, x)

end

defmodule Banshee.Key do

  @behaviour Banshee.Navigator

  def select(key, navs, %{}=data), do: Banshee.select(navs, Map.get(data, key))
  def select(k, n, d) when is_list(d), do: Banshee.select(n, Keyword.get(d, k))

  def select(_, _, _), do: []

  def transform(k, n, %{}=d, x), do: transform(Map, k, n, d, x)
  def transform(k, n, d, x) when is_list(d), do: transform(Keyword, k, n, d, x)
  def transform(_, _, d, _), do: d

  defp transform(mod, key, navs, data, xform) do
    case mod.fetch(data, key) do
      {:ok, val} -> mod.put(data, key, Banshee.transform(navs, val, xform))
      _ -> data
    end
  end

end

defmodule Banshee.Keys do

  @behaviour Banshee.Navigator

  def select(navs, %{}=data), do: Enum.flat_map(Map.keys(data), &Banshee.select(navs, &1))
  def select(n, d) when is_list(d), do: Enum.flat_map(Keyword.keys(d), &Banshee.select(n, &1))
  def select(_, _), do: []

  def select(_, n, d), do: select(n, d)

  def transform(n, %{}=d, x) do
    Enum.reduce(d, %{}, fn {k,v}, acc -> Map.put(acc, transform(n, k, x), v) end)
  end
  def transform(n, d, x) when is_list(d) do
    Enum.reduce(d, %{}, fn {k,v}, acc -> [{transform(n, k, x), v} | acc] end)
  end
  def transform(_, d, _), do: d

  def transform(_, n, d, x), do: transform(n, d, x)

end

defmodule Banshee.Vals do

  @behaviour Banshee.Navigator

  def select(navs, %{}=data), do: Enum.flat_map(Map.values(data), &Banshee.select(navs, &1))
  def select(n, d) when is_list(d), do: Enum.flat_map(Keyword.values(d), &Banshee.select(n, &1))
  def select(_, _), do: []

  def select(_, n, d), do: select(n, d)

  def transform(n, %{}=d, x) do
    Enum.reduce(d, %{}, fn {k,v}, acc -> Map.put(acc, k, transform(n, v, x)) end)
  end
  def transform(n, d, x) when is_list(d) do
    Enum.reduce(d, [], fn {k,v}, acc -> [{k, transform(n, v, x)} | acc] end)
  end
  def transform(_, d, _), do: d

  def transform(_, n, d, x), do: transform(n, d, x)

end
