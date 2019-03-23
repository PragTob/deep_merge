defmodule MyStruct do
  @moduledoc false
  defstruct [:attrs]
end

defimpl DeepMerge.Resolver, for: MyStruct do
  def resolve(original, override = %{__struct__: MyStruct}, resolver) do
    Map.merge(original, override, resolver)
  end

  def resolve(_, override, _) do
    override
  end
end
