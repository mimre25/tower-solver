defmodule PermutationsTest do
  use ExUnit.Case
  doctest Permutations

  test "Empty list returns empty list" do
    assert Permutations.permutate([]) == []
  end

  test "Empty single element returns same list" do
    assert Permutations.permutate([1]) == [[1]]
  end

  test "Two-element list" do
    assert Permutations.permutate([1, 2]) == [[1, 2], [2, 1]]
  end

  test "Three-element list" do
    assert Permutations.permutate([1, 2, 3]) == [
             [1, 2, 3],
             [2, 1, 3],
             [2, 3, 1],
             [1, 3, 2],
             [3, 1, 2],
             [3, 2, 1]
           ]
  end

  test "Four-element list" do
    assert Permutations.permutate([1, 2, 3, 4]) == [
             [1, 2, 3, 4],
             [2, 1, 3, 4],
             [2, 3, 1, 4],
             [2, 3, 4, 1],
             [1, 3, 2, 4],
             [3, 1, 2, 4],
             [3, 2, 1, 4],
             [3, 2, 4, 1],
             [1, 3, 4, 2],
             [3, 1, 4, 2],
             [3, 4, 1, 2],
             [3, 4, 2, 1],
             [1, 2, 4, 3],
             [2, 1, 4, 3],
             [2, 4, 1, 3],
             [2, 4, 3, 1],
             [1, 4, 2, 3],
             [4, 1, 2, 3],
             [4, 2, 1, 3],
             [4, 2, 3, 1],
             [1, 4, 3, 2],
             [4, 1, 3, 2],
             [4, 3, 1, 2],
             [4, 3, 2, 1]
           ]
  end
end
