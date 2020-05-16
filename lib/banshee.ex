defmodule Banshee do
  @moduledoc """
  
  """

  def select([], data), do: [data]
  def select([nav | navs], data), do: navigate(nav, navs, data)
  
  defp navigate(nav, navs, data) when is_atom(nav), do: nav.select(navs, data) # mod
  defp navigate(nav, navs, data) when is_function(nav, 2), do: nav.(navs, data)
  defp navigate(nav, navs, data) when is_function(nav, 1) do # filter
    if nav.(data), do: select(navs, data), else: []
  end
  defp navigate({fun, arg}, navs, data) when is_function(fun, 2) do # filter + arg
    if fun.(arg, data), do: select(navs, data), else: []
  end

  # selector or filter
  defp navigate({mod, fun}, navs, data) when is_atom(mod) and is_atom(fun) do
    cond do
      function_exported?(mod, fun, 2) -> apply(mod, fun, [navs, data])
      function_exported?(mod, fun, 1) ->
        if apply(mod, fun, [data]), do: select(navs, data), else: []
    end
  end
  defp navigate({mod, arg}, navs, data) when is_atom(mod) do
    cond do
      function_exported?(mod, :select, 3) -> mod.select(arg, navs, data)
      function_exported?(mod, :select, 2) ->
        if mod.select(arg, data), do: select(navs, data), else: []
    end
  end
  # selector or filter with data
  defp navigate({mod, fun, arg}, navs, data) when is_atom(mod) and is_atom(fun) do
    cond do
      function_exported?(mod, fun, 3) -> apply(mod, fun, [arg, navs, data])
      function_exported?(mod, fun, 2) ->
        if apply(mod, fun, [arg, data]), do: select(navs, data), else: []
    end

  end

  # def transform([], data, value), do: data
  
end

defmodule Banshee.All do

  def select(navs, data), do: Enum.flat_map(data, &Banshee.select(navs, &1))
  def select(_, navs, data), do: select(navs, data)

end

defmodule Banshee.Key do

  def select(key, navs, %{}=data), do: Banshee.select(navs, Map.get(data, key))
  def select(key, navs, data) when is_list(data), do: Banshee.select(navs, Keyword.get(data, key))

end

defmodule Banshee.Keys do

  def select(navs, %{}=data), do: Enum.flat_map(Map.keys(data), &Banshee.select(navs, &1))
  def select(navs, data) when is_list(data) do
    Enum.flat_map(Keyword.keys(data), &Banshee.select(navs, &1))
  end
  def select(_, navs, data), do: select(navs, data)

end

defmodule Banshee.Map do

  def select(nav, navs, data) when is_function(nav, 1), do: Banshee.select(navs, nav.(data))
  def select({mod, fun}, navs, data) when is_atom(mod) and is_atom(fun) do
    Banshee.select(navs, apply(mod, fun, [data]))
  end
  def select({mod, fun, arg}, navs, data) when is_atom(mod) and is_atom(fun) do
    Banshee.select(navs, apply(mod, fun, [arg, data]))
  end
  
end

defmodule Banshee.Vals do

  def select(navs, %{}=data), do: Enum.flat_map(Map.values(data), &Banshee.select(navs, &1))
  def select(navs, data) when is_list(data) do
    Enum.flat_map(Keyword.values(data), &Banshee.select(navs, &1))
  end
  def select(_, navs, data), do: select(navs, data)

end
