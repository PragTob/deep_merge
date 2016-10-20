defmodule DeepMerge.MapTest do
  use ExUnit.Case
  doctest DeepMerge.Map
  import DeepMerge.Map

  test "deep_merge/3 with custom resolver shallow" do
    res = deep_merge %{a: [1]}, %{a: [2]}, fn(_key, val1, val2) ->
      val1 ++ val2
    end

    assert res == %{a: [1, 2]}
  end

  test "deep_merge/3 with custom resolver deep" do
    res =
      deep_merge %{a: %{b: [1]}}, %{a: %{b: [2]}},
        fn(_key, val1, val2) ->
          val1 ++ val2
        end

    assert res == %{a: %{b: [1, 2]}}
  end

  test "deep_merge/3 with keyword lists arrays and numbers" do
    resolver = fn
      _, list1, list2 when is_list(list1) and is_list(list2) ->
        Keyword.merge(list1, list2)
      _, num1, num2 when is_number(num1) and is_number(num2) ->
        num1 + num2
      _, val1, _val2 ->
        val1
    end

    res = deep_merge %{a: 1, b: [a: 1, c: 3], d: "foo"},
                               %{a: 2, b: [c: 10, d: 4], d: "bar"},
                               resolver

    assert res == %{a: 3, b: [a: 1, c: 10, d: 4], d: "foo"}
  end
end
