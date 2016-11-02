defmodule DeepMerge.Integration do
  @continue_symbol :__deep_merge_continue

  def do_deep_merge(key, base, override, resolve_function) do
    resolved_value = resolve_function.(key, base, override)
    case resolved_value do
       @continue_symbol ->
        DeepMerge.Resolver.resolve(base, override, resolve_function)
      _anything ->
        resolved_value
    end
  end

  def build_resolver(function) do
    fn(key, orig, over) ->
      do_deep_merge(key, orig, over, function)
    end
  end

  @doc """
  The symbol to return in the function in `deep_merge/3` when deep merging
  should continue as normal.

  ## Examples

      iex> DeepMerge.Integration.continue_deep_merge
      :__deep_merge_continue
  """
  def continue_deep_merge, do: @continue_symbol
end
