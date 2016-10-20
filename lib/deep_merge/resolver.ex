defprotocol DeepMerge.Resolver do
  @fallback_to_any true

  @doc """
  Resolves what happens when this data types is going to be deep merged.
  """
  def resolver(original, override)
end

defimpl DeepMerge.Resolver, for: Map do
  def resolver(original, override) when is_map(override) do
    resolver = fn(_, orig, over) -> DeepMerge.Resolver.resolver(orig, over) end
    Map.merge(original, override, resolver)
  end
  def resolver(_original, override), do: override
end

defimpl DeepMerge.Resolver, for: Any do
  def resolver(_original, override), do: override
end
