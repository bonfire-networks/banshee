defmodule Banshee.Elem do
  @doc """
  A navigator over an element of a tuple.

  Param required: tuple index
  """
  @behaviour Banshee.Navigator

  import Banshee, only: [select: 2, transform: 3]

  def select(index, navs, data)
      when is_tuple(data) and is_integer(index) and index >= 0 and
             index < tuple_size(data),
      do: select(navs, elem(data, index))

  def select(_, _, _), do: []

  def transform(index, navs, data, xform)
      when is_tuple(data) and
             is_integer(index) and index >= 0 and index < tuple_size(data),
      do: put_elem(data, index, transform(navs, elem(data, index), xform))

  def transform(_, _, data, _), do: data
end
