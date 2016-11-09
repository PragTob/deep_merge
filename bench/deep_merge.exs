base_map = (0..50)
           |> Enum.zip(300..350)
           |> Enum.into(%{})

# In the end those are 2 maps with 51 flat keys plus these
orig = Map.merge base_map, %{150 => %{1 => 1, 2 => 2}, 155 => %{y: :x}, 170 => %{"foo" => "bar"}, z: %{ x: 4, y: %{a: 1, b: %{c: 2}, d: %{"hey" => "ho"}}}, a: %{b: %{c: %{a: 99, d: "foo", e: 2}}, m: [33], i: 99, y: "bar"}, b: %{y: [23, 87]}, z: %{xy: %{y: :x}}}
new = Map.merge base_map, %{150 => %{3 => 3}, 160 => %{a: "b"}, z: %{ xui: [44], y: %{b: %{c: 77, d: 55}, d: %{"ho" => "hey", "du" => "nu", "hey" => "ha"}}}, a: %{b: %{c: %{a: 1, b: 2, d: "bar"}}, m: 12, i: 102}, b: %{ x: 65, y: [23]}, z: %{ xy: %{x: :y}}}

simple = fn(_key, _base, override) -> override end
continue_symbol = DeepMerge.continue_deep_merge
continue = fn(_, _, _) -> continue_symbol end

Benchee.run %{
  formatters: [&Benchee.Formatters.Console.output/1],
},
%{
  "Map.merge/2"           => fn -> Map.merge orig, new end,
  "Map.merge/3"           => fn -> Map.merge orig, new, simple end,
  "deep_merge/2"          => fn -> DeepMerge.deep_merge orig, new end,
  "deep_merge/3 continue" => fn -> DeepMerge.deep_merge orig, new, continue end
}
