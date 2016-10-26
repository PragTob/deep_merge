defmodule MyStruct do
  defstruct [:attrs]
end

defimpl DeepMerge.Resolver, for: MyStruct do
  def resolve(original, override = %{__struct__: MyStruct}) do
    resolver = fn(_, orig, over) -> DeepMerge.Resolver.resolve(orig, over) end
    Map.merge(original, override, resolver)
  end
  def resolve(_, override) do
    override
  end
end
