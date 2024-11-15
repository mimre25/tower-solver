defmodule TowerSolverTest do
  alias TowerSolver.Game
  use ExUnit.Case
  doctest TowerSolver

  test "game to_string" do
    assert to_string(
             Game.new(3, %TowerSolver.Constraints{
               top: [1, 1, 1],
               bottom: [2, 2, 2],
               left: [3, 3, 3],
               right: [4, 4, 4]
             })
           ) == """
            | 1 1 1 |
           ===========
           3| 0 0 0 |4
           3| 0 0 0 |4
           3| 0 0 0 |4
           ===========
            | 2 2 2 |
           """

    # "Size: 3\n" <>
    #   "Constraints: [[1, 1, 1]\n[2, 2, 2]\n[3, 3, 3]\n[4, 4, 4]]\n" <>
    #   "000\n000\n000\n"
  end

  test "check validity single direction" do
    assert Game.valid_line?([1, 2, 3], 3)
    assert Game.valid_line?([2, 1, 3], 2)
    assert Game.valid_line?([2, 3, 1], 2)
    assert Game.valid_line?([1, 3, 2], 2)
    assert Game.valid_line?([3, 1, 2], 1)
    assert Game.valid_line?([3, 2, 1], 1)
  end

  test "check validity both directions" do
    assert Game.valid_line?([1, 2, 3], {3, 1})
    assert Game.valid_line?([2, 1, 3], {2, 1})
    assert Game.valid_line?([2, 3, 1], {2, 2})
    assert Game.valid_line?([1, 3, 2], {2, 2})
    assert Game.valid_line?([3, 1, 2], {1, 2})
    assert Game.valid_line?([3, 2, 1], {1, 3})
  end

  test "new" do
    constraints = %TowerSolver.Constraints{
      top: [],
      bottom: [],
      left: [],
      right: []
    }

    assert TowerSolver.Game.new(2, constraints) == %TowerSolver.Game{
             size: 2,
             constraints: constraints,
             board: %ListBoard{board: [[0, 0], [0, 0]]}
           }
  end

  test "game valid?" do
    constraints = %TowerSolver.Constraints{
      top: [3, 2, 1],
      bottom: [1, 2, 2],
      left: [3, 2, 1],
      right: [1, 2, 2]
    }

    game = %TowerSolver.Game{
      size: 3,
      constraints: constraints,
      board: %ListBoard{board: [[1, 2, 3], [2, 3, 1], [3, 1, 2]]}
    }

    assert Game.valid?(game)
  end

  test "solve game" do
    constraints = %TowerSolver.Constraints{
      top: [3, 2, 1],
      bottom: [1, 2, 2],
      left: [3, 2, 1],
      right: [1, 2, 2]
    }

    expected_solution = %TowerSolver.Game{
      size: 3,
      constraints: constraints,
      board: %ListBoard{board: [[1, 2, 3], [2, 3, 1], [3, 1, 2]]}
    }

    game = Game.new(3, constraints)
    [result] = Game.solve(game)
    assert result == expected_solution
  end

  test "solve 6x6 game" do
    constraints = %TowerSolver.Constraints{
      top: [2, 3, 1, 2, 3, 2],
      bottom: [2, 1, 4, 3, 3, 2],
      left: [2, 3, 3, 1, 5, 2],
      right: [2, 3, 2, 5, 1, 2]
    }

    game = Game.new(6, constraints)
    board = game.board
    board = Board.set(board, 0, 1, 2)
    board = Board.set(board, 4, 4, 5)
    board = Board.set(board, 5, 2, 3)
    board = Board.set(board, 5, 4, 1)

    game = %{game | :board => board}

    expected_solution = %TowerSolver.Game{
      size: 6,
      constraints: constraints,
      board: %ListBoard{
        board: [
          [5, 2, 6, 1, 3, 4],
          [3, 5, 1, 6, 4, 2],
          [4, 1, 2, 5, 6, 3],
          [6, 4, 5, 3, 2, 1],
          [1, 3, 4, 2, 5, 6],
          [2, 6, 3, 4, 1, 5]
        ]
      }
    }

    [result] = Game.solve(game)
    assert result == expected_solution
  end
end
