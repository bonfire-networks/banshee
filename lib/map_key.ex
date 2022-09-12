defmodule Banshee.MapKey do
  import Banshee, only: [select: 2, transform: 3]

  def select(key, navs, data) do
    case data do
      %{^key => val} -> select(navs, val)
      _ -> []
    end
  end

  def transform(key, navs, data, xform) do
    case data do
      %{^key => val} -> Map.put(data, key, transform(navs, val, xform))
      _ -> data
    end
  end
end
