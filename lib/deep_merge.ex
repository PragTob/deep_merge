defmodule DeepMerge do
  @moduledoc """
  Provides functionality for deeply/recursively merging entites (normally for
  `Map` and `Keyword`).

  If you want to change the behaviour of a custom struct or something similar,
  please have a look at the `DeepMerge.Resolver` protocol.
  """

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
    DeepMerge.Resolver.resolve(base, override)
  end
end
