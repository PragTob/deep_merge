defprotocol DeepMerge.Resolver do
  @fallback_to_any true

  @doc """
  Resolves what happens when this data types is going to be deep merged.
  """
  def resolve(original, override)
end

defimpl DeepMerge.Resolver, for: Map do
  def resolve(_original, override = %{__struct__: _}) do
    override
  end
  def resolve(original, override) when is_map(override) do
    resolver = fn(_, orig, over) -> DeepMerge.Resolver.resolve(orig, over) end
    Map.merge(original, override, resolver)
  end
  def resolve(_original, override), do: override
end

defimpl DeepMerge.Resolver, for: List do
  def resolve(original = [{_k, _v} | _tail], override = [{_, _} | _]) do
    resolver = fn(_, orig, over) -> DeepMerge.Resolver.resolve(orig, over) end
    Keyword.merge(original, override, resolver)
  end
  def resolve(original = [{_k, _v} | _tail], _override = []) do
    original
  end
  def resolve(_original, override), do: override
end

defimpl DeepMerge.Resolver, for: Any do
  def resolve(_original, override), do: override
end
