# DeepMerge [![Build Status](https://travis-ci.org/PragTob/deep_merge.svg?branch=master)](https://travis-ci.org/PragTob/deep_merge) [![Inline docs](http://inch-ci.org/github/PragTob/deep_merge.svg?branch=master)](http://inch-ci.org/github/PragTob/deep_merge)

Provides functionality for "deep merging" maps and keyword lists in elixir, which is if during merging both values are maps/keyword lists merge them recursively.

```
iex> DeepMerge.deep_merge(%{a: 1, b: [x: 10, y: 9]}, %{b: [y: 20, z: 30], c: 4})
%{a: 1, b: [x: 10, y: 20, z: 30], c: 4}
```

This functionality can be useful for instance when merging a default configuration with a user supplied custom configuration.

```elixir
DeepMerge.deep_merge(default_config, custom_config) # ==> merged configuration
```

I'd like this to be a feature of Elixir itself, however the proposal was rejected hence this library exists.

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

## Customization

By default only maps are deeply merged with other maps and keyword lists are deeply merged with other keyword lists. How this happens is defined in the `DeepMerge.Resolver` protocol. If you want to change this behaviour for a custom struct you provide just implement the protocol for it.

The fallback for `Any` is that the right/side override value is taken into the resulting Map, just like in the normal `Map.merge/2`.
