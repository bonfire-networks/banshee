defmodule Banshee.All do
  @doc "A Navigator that visits every element in a collection. Param ignored."

  @behaviour Banshee.Navigator
  import Banshee.Util, only: [proto: 5]
  
  def select(navs, data) do
    proto(Enumerable, Enum, :flat_map, [data, &Banshee.select(navs, &1)], [])
  end

  def select(_, navs, data), do: select(navs, data)

  def transform(navs, data, transform)
  def transform(navs, data, transform) when is_list(data) do
    Enum.map(data, &Banshee.transform(navs, &1, transform))
  end
  def transform(navs, %MapSet{}=data, transform) do
    Enum.reduce(data, MapSet.new(), fn data, acc ->
      MapSet.put(acc, Banshee.transform(navs, data, transform))
    end)
  end
  def transform(navs, %{}=data, transform) do
    Enum.reduce(data, %{}, fn elem, acc ->
      {k, v} = Banshee.transform(navs, elem, transform)
      Map.put(acc, k, v)
    end)
  end
  def transform(_, data, _), do: data

  def transform(_, navs, data, xf), do: transform(navs, data, xf)

end
