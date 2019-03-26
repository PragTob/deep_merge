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
# Map.merge/2               1592.08 K        0.63 μs  ±2035.06%        0.57 μs        1.18 μs
# Map.merge/3                 89.91 K       11.12 μs    ±83.43%       10.13 μs       27.41 μs
# deep_merge/2                56.08 K       17.83 μs    ±33.18%       16.24 μs       53.73 μs
# deep_merge/3 continue       50.18 K       19.93 μs    ±28.86%       18.49 μs       46.19 μs

# Comparison:
# Map.merge/2               1592.08 K
# Map.merge/3                 89.91 K - 17.71x slower
# deep_merge/2                56.08 K - 28.39x slower
# deep_merge/3 continue       50.18 K - 31.73x slower

# Extended statistics:

# Name                          minimum        maximum    sample size                     mode
# Map.merge/2                   0.54 μs    17047.00 μs         3.86 M                  0.57 μs
# Map.merge/3                   9.93 μs     2784.51 μs       422.25 K                 10.09 μs
# deep_merge/2                 15.88 μs      450.84 μs       269.07 K                 16.13 μs
# deep_merge/3 continue        18.02 μs      933.54 μs       242.12 K                 18.26 μs

# Memory usage statistics:

# Name                     Memory usage
# Map.merge/2                   0.23 KB
# Map.merge/3                  15.50 KB - 68.41x memory usage
# deep_merge/2                 23.61 KB - 104.21x memory usage
# deep_merge/3 continue        23.60 KB - 104.17x memory usage

# **All measurements for memory usage were the same**
