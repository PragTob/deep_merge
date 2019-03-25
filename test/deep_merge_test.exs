defmodule DeepMergeTest do
  use ExUnit.Case
  doctest DeepMerge
  import DeepMerge

  test "with different keyword list & list combinations" do
    assert deep_merge([a: [b: []], f: 5], a: [b: [c: 2]]) == [f: 5, a: [b: [c: 2]]]

    assert deep_merge([a: [b: [c: 2]], f: 5], a: [b: []]) == [f: 5, a: [b: [c: 2]]]

    assert deep_merge([a: [b: [c: 2]], f: 5], a: [b: [1, 2, 3]]) == [f: 5, a: [b: [1, 2, 3]]]

    assert deep_merge([a: [b: [1, 2, 3]], f: 5], a: [b: [c: 2]]) == [f: 5, a: [b: [c: 2]]]

    assert deep_merge([a: [b: []], f: 5], a: [b: []]) == [f: 5, a: [b: []]]
  end

  defmodule User do
    defstruct [:attrs]
  end

  describe ".deep_merge/2" do
    test "doesn't attempt to merge structs" do
      original = %{a: %User{attrs: %{b: 1}}}
      override = %{a: %User{attrs: %{c: 2}}}
      assert deep_merge(original, override) == override
    end

    test "merges Structs with the Resolver protocol implemented" do
      original = %{a: %MyStruct{attrs: %{b: 1}}}
      override = %{a: %MyStruct{attrs: %{c: 2}}}

      assert deep_merge(original, override) == %{a: %MyStruct{attrs: %{b: 1, c: 2}}}
    end

    test "merges Structs with protocol implemented even in the top level" do
      original = %MyStruct{attrs: %{b: 1, c: 0}}
      override = %MyStruct{attrs: %{c: 2, e: 4}}

      assert deep_merge(original, override) == %MyStruct{attrs: %{b: 1, c: 2, e: 4}}
    end

    test "doesn't merge structs without the protocol implemented" do
      original = %{a: %MyStruct{attrs: %{b: 1}}}
      override = %{a: %User{attrs: %{c: 2}}}
      assert deep_merge(original, override) == override
    end

    test "doesn't attempt to merge maps and structs" do
      with_map = %{a: %{attrs: %{b: 1}}}
      with_struct = %{a: %User{attrs: %{c: 2}}}

      assert deep_merge(with_map, with_struct) == with_struct
      assert deep_merge(with_struct, with_map) == with_map
    end

    test "uses override semantics when mixing maps and kwlists" do
      assert deep_merge(%{a: 1}, b: 2) == [b: 2]
      assert deep_merge([b: 2], %{a: 1}) == %{a: 1}
    end

    test "errors out with incompatible types" do
      assert_incompatible(fn -> deep_merge(%{a: 1}, 2) end)
      assert_incompatible(fn -> deep_merge(2, %{b: 2}) end)
      assert_incompatible(fn -> deep_merge(1, 2) end)
      assert_incompatible(fn -> deep_merge(:atom, :other_atom) end)
    end
  end

  describe ".deep_merge/3" do
    def kwlist_avoider do
      fn
        _, original, override when is_list(original) and is_list(override) ->
          override

        _, _original, _override ->
          DeepMerge.continue_deep_merge()
      end
    end

    test "can successfully avoid marging kwlists" do
      assert deep_merge([a: :b], [c: :d], kwlist_avoider()) == [c: :d]
      assert deep_merge(%{a: :b}, %{c: :d}, kwlist_avoider()) == %{a: :b, c: :d}
      base = %{a: [b: 1], c: %{d: 1, e: %{f: 2}}}
      override = %{a: [c: 3], c: %{e: %{g: 10}}}
      expected = %{a: [c: 3], c: %{d: 1, e: %{f: 2, g: 10}}}
      assert deep_merge(base, override, kwlist_avoider()) == expected
    end

    def number_adder do
      fn
        _, original, override when is_number(original) and is_number(override) ->
          original + override

        _, _original, _override ->
          DeepMerge.continue_deep_merge()
      end
    end

    test "optional function can be used to add numbers if desired" do
      assert deep_merge(
               %{a: 1, b: [c: 2]},
               %{a: -1, b: [c: 5, d: 1], e: ""},
               number_adder()
             ) == %{a: 0, b: [c: 7, d: 1], e: ""}
    end

    test "uses override semantics when mixing maps and kwlists" do
      assert deep_merge(%{a: 1}, [b: 2], number_adder()) == [b: 2]
      assert deep_merge([b: 2], %{a: 1}, number_adder()) == %{a: 1}
    end

    test "errors out with incompatible types" do
      assert_incompatible(fn -> deep_merge(%{a: 1}, 2, number_adder()) end)
      assert_incompatible(fn -> deep_merge(2, %{b: 2}, number_adder()) end)
      assert_incompatible(fn -> deep_merge(1, 2, number_adder()) end)
      assert_incompatible(fn -> deep_merge(:atom, :other_atom, number_adder()) end)
    end
  end

  defp assert_incompatible(function) do
    assert_raise FunctionClauseError, function
  end
end
