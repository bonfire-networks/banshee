defmodule Banshee.All do
  @doc "A Navigator that visits every element in a collection. Param ignored."

  @behaviour Banshee.Navigator
  import Banshee.Util, only: [proto: 5]
  
  def select(navs, data) do
    proto(Enumerable, Enum, :flat_map, [data, &Banshee.select(navs, &1)], [])
  end

  def select(_, navs, data), do: select(navs, data)

  def transform(navs, data, transform)
  def transform(navs, data, transform) do
    proto(Enumerable, Enum, :map, [data, &Banshee.transform(navs, &1, transform)], data)
  end

  def transform(_param, navs, data, transform)
  def transform(_, navs, data, xf), do: transform(navs, data, xf)

end
