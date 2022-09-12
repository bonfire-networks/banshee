defmodule Banshee.MapVals do
  @doc "A Navigator over the values of a map"

  @behaviour Banshee.Navigator

  def select(navs, %{} = data),
    do: Enum.flat_map(Map.values(data), &Banshee.select(navs, &1))

  def select(_, _), do: []

  def select(_, n, d), do: select(n, d)

  def transform(n, %{} = d, x) do
    Enum.reduce(d, %{}, fn {k, v}, acc ->
      Map.put(acc, k, Banshee.transform(n, v, x))
    end)
  end

  def transform(_, d, _), do: d

  def transform(_, n, d, x), do: transform(n, d, x)
end
