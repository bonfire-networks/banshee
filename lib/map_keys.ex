defmodule Banshee.MapKeys do
  @doc "A Navigator over the keys of a map"

  @behaviour Banshee.Navigator

  def select(navs, %{} = data),
    do: Enum.flat_map(Map.keys(data), &Banshee.select(navs, &1))

  def select(n, d) when is_list(d),
    do: Enum.flat_map(Keyword.keys(d), &Banshee.select(n, &1))

  def select(_, _), do: []

  def select(_, n, d), do: select(n, d)

  def transform(n, %{} = d, x) do
    Enum.reduce(d, %{}, fn {k, v}, acc ->
      Map.put(acc, Banshee.transform(n, k, x), v)
    end)
  end

  def transform(_, d, _), do: d

  def transform(_, n, d, x), do: transform(n, d, x)
end
