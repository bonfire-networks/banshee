defmodule Banshee.Fork do
  @doc """
  A Navigator that traverses multiple Navigator paths.

  During select, returns results for all paths. During transform,
  transforms along all paths in sequence.

  Param required: list of navigator paths
  """

  @behaviour Banshee.Navigator
  @type path :: Banshee.navigator() | [Banshee.navigator()]

  import Banshee, only: [select: 2, transform: 3]

  @spec select(paths :: [path], navs :: [Banshee.navigator()], data :: term) ::
          [term]
  def select(paths, navs, data) when is_list(paths) do
    Enum.flat_map(paths, &sel(&1, navs, data))
  end

  defp sel(path, navs, data) when is_list(path), do: select(path ++ navs, data)
  defp sel(path, navs, data), do: select([path | navs], data)

  @spec transform(
          paths :: [path],
          navs :: [Banshee.navigator()],
          data :: term,
          transform :: (term -> term)
        ) :: term
  def transform(paths, navs, data, xf) do
    Enum.reduce(paths, data, &trans(&1, navs, &2, xf))
  end

  def trans(p, n, d, x) when is_list(p), do: transform(p ++ n, d, x)
  def trans(p, n, d, x), do: transform([p | n], d, x)
end
