base_map =
  0..50
  |> Enum.zip(300..350)
  |> Enum.into(%{})

# In the end those are 2 maps with 51 flat keys plus these
orig =
  Map.merge(base_map, %{
    150 => %{1 => 1, 2 => 2},
    155 => %{y: :x},
    170 => %{"foo" => "bar"},
    az: %{x: 4, y: %{a: 1, b: %{c: 2}, d: %{"hey" => "ho"}}},
    a: %{b: %{c: %{a: 99, d: "foo", e: 2}}, m: [33], i: 99, y: "bar"},
    b: %{y: [23, 87]},
    z: %{xy: %{y: :x}}
  })

new =
  Map.merge(base_map, %{
    150 => %{3 => 3},
    160 => %{a: "b"},
    az: %{xui: [44], y: %{b: %{c: 77, d: 55}, d: %{"ho" => "hey", "du" => "nu", "hey" => "ha"}}},
    a: %{b: %{c: %{a: 1, b: 2, d: "bar"}}, m: 12, i: 102},
    b: %{x: 65, y: [23]},
    z: %{xy: %{x: :y}}
  })

simple = fn _key, _base, override -> override end
continue_symbol = DeepMerge.continue_deep_merge()
continue = fn _, _, _ -> continue_symbol end

Benchee.run(
  %{
    "Map.merge/2" => fn -> Map.merge(orig, new) end,
    "Map.merge/3" => fn -> Map.merge(orig, new, simple) end,
    "deep_merge/2" => fn -> DeepMerge.deep_merge(orig, new) end,
    "deep_merge/3 continue" => fn -> DeepMerge.deep_merge(orig, new, continue) end
  },
  memory_time: 1,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}]
)

# tobi@speedy:~/github/deep_merge/benches(master)$ mix run bench/deep_merge.exs
# Operating System: Linux
# CPU Information: Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz
# Number of Available Cores: 8
# Available memory: 15.61 GB
# Elixir 1.8.1
# Erlang 21.2.7

# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 1 s
# parallel: 1
# inputs: none specified
# Estimated total run time: 32 s


# Benchmarking Map.merge/2...
# Benchmarking Map.merge/3...
# Benchmarking deep_merge/2...
# Benchmarking deep_merge/3 continue...

# Name                            ips        average  deviation         median         99th %
# Map.merge/2               1619.46 K        0.62 μs  ±3688.23%        0.55 μs        1.07 μs
# Map.merge/3                 86.49 K       11.56 μs    ±87.01%        9.89 μs       36.62 μs
# deep_merge/2                56.49 K       17.70 μs    ±46.26%       15.96 μs       40.55 μs
# deep_merge/3 continue       50.67 K       19.74 μs    ±31.04%       18.18 μs       45.09 μs

# Comparison:
# Map.merge/2               1619.46 K
# Map.merge/3                 86.49 K - 18.72x slower
# deep_merge/2                56.49 K - 28.67x slower
# deep_merge/3 continue       50.67 K - 31.96x slower

# Extended statistics:

# Name                          minimum        maximum    sample size                     mode
# Map.merge/2                   0.52 μs    28978.90 μs         3.99 M                  0.54 μs
# Map.merge/3                   9.70 μs     3729.56 μs       406.55 K                  9.85 μs
# deep_merge/2                 15.53 μs     2136.29 μs       270.02 K                 15.73 μs
# deep_merge/3 continue        17.67 μs     1067.68 μs       244.03 K                 17.89 μs

# Memory usage statistics:

# Name                     Memory usage
# Map.merge/2                   0.23 KB
# Map.merge/3                  16.22 KB - 71.59x memory usage
# deep_merge/2                 23.79 KB - 105.00x memory usage
# deep_merge/3 continue        22.87 KB - 100.93x memory usage

# **All measurements for memory usage were the same**
