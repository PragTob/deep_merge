# DeepMerge [![Build Status](https://travis-ci.org/PragTob/deep_merge.svg?branch=master)](https://travis-ci.org/PragTob/deep_merge) [![Inline docs](http://inch-ci.org/github/PragTob/deep_merge.svg?branch=master)](http://inch-ci.org/github/PragTob/deep_merge)

Provides functionality for "deep merging" maps and keyword lists in elixir, which is if during merging both values at the same key are maps/keyword lists merge them recursively. This is done via a protocol so can be extended for your own structs/data types if needbe.

```
iex> DeepMerge.deep_merge(%{a: 1, b: [x: 10, y: 9]}, %{b: [y: 20, z: 30], c: 4})
%{a: 1, b: [x: 10, y: 20, z: 30], c: 4}
```

This functionality can be useful for instance when merging a default configuration with a user supplied custom configuration:

```elixir
DeepMerge.deep_merge(default_config, custom_config) # ==> merged configuration
```

I'd like this to be a feature of Elixir itself, however the proposal [was rejected](https://github.com/elixir-lang/elixir/pull/5339) hence this library exists :)

## Installation

1. Add `deep_merge` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:deep_merge, "~> 0.1.0"}]
  end
  ```

2. Ensure `deep_merge` is started before your application:

  ```elixir
  def application do
    [applications: [:deep_merge]]
  end
  ```

## General Usage - deep_merge/2

Using this library is quite simple (and you might also want to look at the exdocs) - just pass two structures to be deep merged into `DeepMerge.deep_merge/2`:

```elixir
iex> DeepMerge.deep_merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: %{y: 20, z: 30}, c: 4})
%{a: 1, b: %{x: 10, y: 20, z: 30}, c: 4}

iex> DeepMerge.deep_merge([a: 1, b: [x: 10, y: 9]], [b: [y: 20, z: 30], c: 4])
[a: 1, b: [x: 10, y: 20, z: 30], c: 4]
```

It is worth noting that structs are not deeply merged - not with each other and not with normal maps. This is because structs, while internally a map, are more like their own data types and therefore should not be deeply merged in my opinion... unless you implement the protocol provided by this library for them.

## Customization via protocols

What is merged and how is defined by implementing the `DeepMerge.Resolver` protocol. This library implements it for `Map`, `List` and falls back to `Any` (where the right hand side value/override is taken). You can check out the details [here](https://github.com/PragTob/deep_merge/blob/master/lib/deep_merge/resolver.ex). If you want to change this behavior for a custom struct you just have to adopt the behavior for it:

```elixir
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

In this implementation, `MyStruct` structs are merged with other `MyStruct` structs. The arguments passed to `resolve` are the original value (left hand side) and the override value (right hand side, which would normally replace the original). The third parameter is a `resolver` function which you can pass to `Map.merge/3`/`Keyword.merge/3` to continue the deep merge.

## Customization via deep_merge/3

There is another deep merge variant that is a bit like `Map.merge/3` as it takes an additional function which you can use to alter the deep merge behavior:

```elixir
iex> resolver = fn
...> (_, original, override) when is_list(original) and is_list(override) ->
...>   override
...> (_, _original, _override) ->
...>   DeepMerge.continue_deep_merge
...> end
iex> DeepMerge.deep_merge(%{a: %{b: 1}, c: [d: 1]},
...> %{a: %{z: 5}, c: [x: 0]}, resolver)
%{a: %{b: 1, z: 5}, c: [x: 0]}
```

This function is called for a given merge conflict with the key where it occured and the two conflicting values. Whatever value is returned in this function is inserted at that point in the structure - unless `DeepMerge.continue_deep_merge` is returned in which case the deep merge continues as normal.

When would you want to use this versus a protocol? The best use case I can think of is when you want to alter behavior for which a protocol is already implemented or if you care about specific keys.

In the example above the behavior is changed so the keyword lists are not deep_merged (if they were the result would contain `c: [d: 1, x:0]`), but maps still are if that's what you are looking for.

## Do I really need a library for this?

Well not necessarily, no. There are [very simple implementations for maps that use Map.merge/3](http://stackoverflow.com/a/38865647).

There are subtle things that can be missed there though, for one the most simple implementation also merges structs which is not always what you want. For Keyword lists on the other hand you gotta be careful that you don't accidentally merge keyword lists with lists as that's [totally possible](https://github.com/elixir-lang/elixir/issues/5395) atm.

This library takes care of those problems and will take care of further problems/edge cases should they appear so you can focus on your business logic.

At the same time it offers extension mechanisms through protocols and a function in `deep_merge/3`. So, it should be adjustable to your use case and if not please open an issue :)
