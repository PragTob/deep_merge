defmodule DeepMerge do
  @moduledoc """
  Provides functionality for deeply/recursively merging entites (normally for
  `Map` and `Keyword`).

  If you want to change the behaviour of a custom struct or something similar,
  please have a look at the `DeepMerge.Resolver` protocol.
  """

  @continue_symbol :__deep_merge_continue

  @doc """
  Deeply merges two maps or keyword list, meaning that if two conflicting values
  are maps or keyword lists themselves then they will also be merged.

  This is rather similar to `Map.merge/2` and `Keyword.merge/2`. However, it
  always applies merging to both maps and keyword lists and also merges those
  recursively.

  It does not merge structs or structs with maps. If you want structs to be
  merged then please have a look at the `DeepMerge.Resolver` protocol and
  consider implementing it.

  ## Examples

      iex> DeepMerge.deep_merge(%{a: 1, b: [x: 10, y: 9]}, %{b: [y: 20, z: 30], c: 4})
      %{a: 1, b: [x: 10, y: 20, z: 30], c: 4}

      iex> DeepMerge.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: %{y: 20, z: 30}, c: 4})
      %{a: 1, b: %{x: 10, y: 20, z: 30}, c: 4}

      iex> DeepMerge.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: %{y: 20, z: 30}, c: 4})
      %{a: 1, b: %{x: 10, y: 20, z: 30}, c: 4}

      iex> DeepMerge.deep_merge([a: 1, b: [x: 10, y: 9]], [b: [y: 20, z: 30], c: 4])
      [a: 1, b: [x: 10, y: 20, z: 30], c: 4]

      iex> DeepMerge.deep_merge(%{a: 1, b: 2}, %{b: 3, c: 4})
      %{a: 1, b: 3, c: 4}

      iex> DeepMerge.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: 5, c: 4})
      %{a: 1, b: 5, c: 4}

      iex> DeepMerge.deep_merge([a: [b: [c: 1, d: 2], e: [24]]], [a: [b: [f: 3], e: [42, 100]]])
      [a: [b: [c: 1, d: 2, f: 3], e: [42, 100]]]

      iex> DeepMerge.deep_merge(%{a: 1, b: 5}, %{b: %{x: 10, y: 9}, c: 4})
      %{a: 1, b: %{x: 10, y: 9}, c: 4}

      iex> DeepMerge.deep_merge(%{a: [b: %{c: [d: "foo", e: 2]}]}, %{a: [b: %{c: [d: "bar"]}]})
      %{a: [b: %{c: [e: 2, d: "bar"]}]}
  """
  def deep_merge(base, override) do
    deep_merge base, override, fn(_, _, _) -> @continue_symbol end
  end

  @doc """

  ## Examples

      iex> resolver = fn
      ...> (_, original, override) when is_list(original) and is_list(override) ->
      ...>   override
      ...> (_, _original, _override) ->
      ...>   DeepMerge.continue_deep_merge
      ...> end
      iex> DeepMerge.deep_merge(%{a: %{b: 1}, c: [d: 1]},
      ...> %{a: %{z: 5}, c: [x: 0]}, resolver)
      %{a: %{b: 1, z: 5}, c: [x: 0]}
  """
  def deep_merge(base, override, resolve_function) do
    resolver = build_resolver(resolve_function)
    resolver.(nil, base, override)
  end


  @doc """
  The symbol to return in the function in `deep_merge/3` when deep merging
  should continue as normal.

  ## Examples

      iex> DeepMerge.continue_deep_merge
      :__deep_merge_continue
  """
  def continue_deep_merge, do: @continue_symbol

  defp build_resolver(resolve_function) do
    my_resolver = fn(key, base, override, fun) ->
      resolved_value = resolve_function.(key, base, override)
      case resolved_value do
         @continue_symbol ->
           continue_deep_merge(base, override, fun)
        _anything ->
          resolved_value
      end
    end

    rebuild_resolver(my_resolver)
  end

  defp rebuild_resolver(resolve_function) do
    fn(key, base, override) ->
      resolve_function.(key, base, override, resolve_function)
    end
  end

  defp continue_deep_merge(base, override, fun) do
    resolver = rebuild_resolver(fun)
    DeepMerge.Resolver.resolve(base, override, resolver)
  end

end
