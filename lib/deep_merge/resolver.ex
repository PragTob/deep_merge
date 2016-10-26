defprotocol DeepMerge.Resolver do
  @moduledoc """
  Protocol defining how conflicts during a conflict should be resolved per type.
  """
  @fallback_to_any true

  @doc """
  Resolves what happens when this data types is going to be deep merged and the
  value for a paticular key already exists.

  The passed in values are `original` the value in the original data structure,
  usually left side argument, and `override` the value with which `original`
  would be overridden in a normal `merge/2`.

  An example implementation might look like this:

  ```
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
  ```
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
