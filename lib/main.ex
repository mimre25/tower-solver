defmodule TowerSolver.CLI do
  @moduledoc """
  pass
  """
  def main(_args \\ []) do
    constraints = %TowerSolver.Constraints{
      top: [2, 3, 1, 2, 3, 2],
      bottom: [2, 1, 4, 3, 3, 2],
      left: [2, 3, 3, 1, 5, 2],
      right: [2, 3, 2, 5, 1, 2]
    }

    game = TowerSolver.Game.new(6, constraints)
    board = game.board

    board = TowerSolver.Board.set(board, 0, 1, 2)
    board = TowerSolver.Board.set(board, 4, 4, 5)
    board = TowerSolver.Board.set(board, 5, 2, 3)
    board = TowerSolver.Board.set(board, 5, 4, 1)

    game = %{game | :board => board}
    solutions = TowerSolver.Game.solve(game)
    _ = Enum.map(solutions, fn x -> IO.puts("#{x}\n\n") end)
    IO.puts("Found #{length(solutions)} solutions")
  end
end
