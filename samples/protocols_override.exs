defimpl DeepMerge.Resolver, for: Map do
  def resolve(_original, override), do: override
end

IO.inspect DeepMerge.deep_merge(%{a: %{b: 2}}, %{a: %{c: 3}})
