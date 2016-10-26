defmodule MyStruct do
  defstruct [:attrs]
end

defimpl DeepMerge.Resolver, for: MyStruct do
  def resolve(original, override = %{__struct__: MyStruct}, fun) do
    resolver = fn(_, orig, over) -> DeepMerge.Resolver.resolve(orig, over, fun) end
    Map.merge(original, override, resolver)
  end
  def resolve(_, override, _) do
    override
  end
end
