defmodule DeepMerge.Map do
  @doc """
  `deep_merge` implementation that builds upon the more general
  `DeepMerge.Map.deep_merge/3` to provide its merging capability.

  Merges two maps similar to `Map.merge/2`, but with the important difference
  that if keys exist in both maps and their value is also a map it will
  recursively also merge these maps. If a value for a duplicated key is not a
  map it will prefer the value present in `override`.

  For maps without maps as possible values it behaves exactly like `Map.merge/2`

  iex> DeepMerge.Map.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: %{y: 20, z: 30}, c: 4})
  %{a: 1, b: %{x: 10, y: 20, z: 30}, c: 4}

  iex> DeepMerge.Map.deep_merge(%{a: 1, b: 2}, %{b: 3, c: 4})
  %{a: 1, b: 3, c: 4}

  iex> DeepMerge.Map.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: 5, c: 4})
  %{a: 1, b: 5, c: 4}

  iex> DeepMerge.Map.deep_merge(%{a: 1, b: 5}, %{b: %{x: 10, y: 9}, c: 4})
  %{a: 1, b: %{x: 10, y: 9}, c: 4}

  iex> DeepMerge.Map.deep_merge(%{a: %{b: %{c: %{d: "foo", e: 2}}}}, %{a: %{b: %{c: %{d: "bar"}}}})
  %{a: %{b: %{c: %{d: "bar", e: 2}}}}
  """
  def deep_merge(base_map, override) do
    deep_merge(base_map, override, fn(_key, _base, override) -> override end)
  end

  @doc """

  And adjustable version of `deep_merge/2` where one can specify the resolver
  function akin to `Map.merge/3` which gets called if a key exists in both maps
  and is not a map.

  This can also be practical if you want to merge further values like lists.

  iex> DeepMerge.Map.deep_merge(%{a: %{y: "bar", z: "bar"}, b: 2}, %{a: %{y: "foo"}, b: 3, c: 4}, fn(_, _, _) -> :conflict end)
  %{a: %{y: :conflict, z: "bar"}, b: :conflict, c: 4}

  iex> simple_resolver = fn(_key, base, _override) -> base end
  iex> DeepMerge.Map.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: 5, c: 4}, simple_resolver)
  %{a: 1, b: %{x: 10, y: 9}, c: 4}

  iex> list_merger = fn
  ...> _, list1, list2 when is_list(list1) and is_list(list2) ->
  ...>   list1 ++ list2
  ...> _, _, override ->
  ...>   override
  ...> end
  iex> DeepMerge.Map.deep_merge(%{a: %{b: [1]}, c: 2}, %{a: %{b: [2]}, c: 100}, list_merger)
  %{a: %{b: [1, 2]}, c: 100}
  """
  def deep_merge(base_map, override_map, fun) do
    # build a function to resolve the merges here and then use an actual
    # do_deep_merge function to do the merges and refer to that one
    # when really merging within the built functions

    Map.merge base_map, override_map, build_deep_merge_resolver(fun)
  end

  defp build_deep_merge_resolver(fun) do
    fn
      _key, base_map, override_map when is_map(base_map) and is_map(override_map) ->
        deep_merge(base_map, override_map, fun)
      key, base, override ->
        fun.(key, base, override)
    end
  end
end
