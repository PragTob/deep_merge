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

  defmodule User do
    defstruct [:attrs]
  end

  test "deep_merge/2 doesn't attempt to merge structs" do
    original = %{a: %User{attrs: %{b: 1}}}
    override = %{a: %User{attrs: %{c: 2}}}
    assert deep_merge(original, override) == override
  end

  test "deep_merge/2 merges Structs with the Resolver protocol implemented" do
    original = %{a: %MyStruct{attrs: %{b: 1}}}
    override = %{a: %MyStruct{attrs: %{c: 2}}}
    assert deep_merge(original, override) ==
      %{a: %MyStruct{attrs: %{b: 1, c: 2}}}
  end

  test "deep_merge/2 merges Structs with protocol implemented top level" do
    original = %MyStruct{attrs: %{b: 1, c: 0}}
    override = %MyStruct{attrs: %{c: 2, e: 4}}
    assert deep_merge(original, override) ==
      %MyStruct{attrs: %{b: 1, c: 2, e: 4}}
  end

  test "deep_merge/2 doesn't merge structs without the protocol implemented" do
    original = %{a: %MyStruct{attrs: %{b: 1}}}
    override = %{a: %User{attrs: %{c: 2}}}
    assert deep_merge(original, override) == override
  end

  test "deep_merge/2 doesn't attempt to merge maps and structs" do
    with_map    = %{a: %{attrs: %{b: 1}}}
    with_struct = %{a: %User{attrs: %{c: 2}}}

    assert deep_merge(with_map, with_struct) == with_struct
    assert deep_merge(with_struct, with_map) == with_map
  end

  def kwlist_avoider do
    fn
    (_, original, override) when is_list(original) and is_list(override) ->
     override
    (_, _original, _override) ->
     DeepMerge.continue_deep_merge
    end
  end

  test "deep_merge/3 can successfully avoid marging kwlists" do
    assert deep_merge([a: :b], [c: :d], kwlist_avoider) == [c: :d]
    assert deep_merge(%{a: :b}, %{c: :d}, kwlist_avoider) == %{a: :b, c: :d}
    base = %{a: [b: 1], c: %{d: 1, e: %{f: 2}}}
    override = %{a: [c: 3], c: %{e: %{g: 10}}}
    expected = %{a: [c: 3], c: %{d: 1, e: %{f: 2, g: 10}}}
    assert deep_merge(base, override, kwlist_avoider) == expected
  end

  def number_adder do
    fn
    (_, original, override) when is_number(original) and is_number(override) ->
     original + override
    (_, _original, _override) ->
     DeepMerge.continue_deep_merge
    end
  end
  test "deep_merge/3 optional function can be used to add numbers if desired" do
    assert deep_merge(%{a: 1, b: [c: 2]},
                      %{a: -1, b: [c: 5, d: 1], e: ""},
                      number_adder) == %{a: 0, b: [c: 7, d: 1], e: ""}
  end
end
