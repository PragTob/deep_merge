defmodule DeepMerge do
  @doc """

  ## Examples

      iex> DeepMerge.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: %{y: 20, z: 30}, c: 4})
      %{a: 1, b: %{x: 10, y: 20, z: 30}, c: 4}

      iex> DeepMerge.deep_merge(%{a: 1, b: 2}, %{b: 3, c: 4})
      %{a: 1, b: 3, c: 4}

      iex> DeepMerge.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: 5, c: 4})
      %{a: 1, b: 5, c: 4}

      iex> DeepMerge.deep_merge(%{a: 1, b: 5}, %{b: %{x: 10, y: 9}, c: 4})
      %{a: 1, b: %{x: 10, y: 9}, c: 4}

      iex> DeepMerge.deep_merge(%{a: %{b: %{c: %{d: "foo", e: 2}}}}, %{a: %{b: %{c: %{d: "bar"}}}})
      %{a: %{b: %{c: %{d: "bar", e: 2}}}}
  """
  def deep_merge(base, override) do
    DeepMerge.Resolver.resolver(base, override)
  end
end
