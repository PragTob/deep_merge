defprotocol DeepMerge.Resolver do
  @moduledoc """
  Protocol defining how conflicts during deep_merge should be resolved.

  As part of the DeepMerge library this protocol is already implemented for
  `Map` and `List` as well as a fallback to `Any`.
  """
  @fallback_to_any true

  @doc """
  Defines what happens when a merge conflict occurs on this data type during a
  deep_merge.

  Can be implemented for additional data types to implement custom deep merging
  behavior.

  The passed in values are:
    * `original` - the value in the original data structure, usually left side
    argument
    * `override` - the value with which `original` would be overridden in a
    normal `merge/2`
    * `resolver` - the function used by DeepMerge to resolve merge conflicts,
    i.e. what you can pass to `Map.merge/3` and `Keyword.merge/3` to continue
    deeply merging.

  An example implementation might look like this if you want to deeply merge
  your struct if the other value also is a struct:

  ```
  defmodule MyStruct do
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
  ```
  """
  def resolve(original, override, resolver)
end

defimpl DeepMerge.Resolver, for: Map do
  def resolve(_original, override = %{__struct__: _}, _fun) do
    override
  end
  def resolve(original, override, resolver) when is_map(override) do
    Map.merge(original, override, resolver)
  end
  def resolve(_original, override, _fun), do: override
end

defimpl DeepMerge.Resolver, for: List do
  def resolve(original = [{_k, _v} | _], override = [{_, _} | _], resolver) do
    Keyword.merge(original, override, resolver)
  end
  def resolve(original = [{_k, _v} | _tail], _override = [], _fun) do
    original
  end
  def resolve(_original, override, _fun), do: override
end

defimpl DeepMerge.Resolver, for: Any do
  def resolve(_original, override, _fun), do: override
end
