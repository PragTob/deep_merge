defmodule DeepMerge do
  @doc """

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
