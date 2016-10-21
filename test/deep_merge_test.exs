defmodule DeepMergeTest do
  use ExUnit.Case
  doctest DeepMerge
  import DeepMerge

  test "deep_merge/2 with different keyword list & list combinations" do
    assert deep_merge([a: [b: []], f: 5], [a: [b: [c: 2]]]) ==
           [f: 5, a: [b: [c: 2]]]
    assert deep_merge([a: [b: [c: 2]], f: 5], [a: [b: []]]) ==
           [f: 5, a: [b: [c: 2]]]
    assert deep_merge([a: [b: [c: 2]], f: 5], [a: [b: [1, 2, 3]]]) ==
           [f: 5, a: [b: [1, 2, 3]]]
    assert deep_merge([a: [b: [1, 2, 3]], f: 5], [a: [b: [c: 2]]]) ==
           [f: 5, a: [b: [c: 2]]]
    assert deep_merge([a: [b: []], f: 5], [a: [b: []]]) ==
           [f: 5, a: [b: []]]
  end
end
