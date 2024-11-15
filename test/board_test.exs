defmodule BoardTest do
  use ExUnit.Case
  doctest Board

  test "rows" do
    lboard = %ListBoard{board: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]}
    tboard = %TupleBoard{board: {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}}

    assert Board.rows(lboard) == [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    assert Board.rows(tboard) == [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  end

  test "cols" do
    lboard = %ListBoard{board: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]}
    tboard = %TupleBoard{board: {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}}

    assert Board.cols(lboard) == [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
    assert Board.cols(tboard) == [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
  end
end
