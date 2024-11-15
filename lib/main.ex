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
    game = TowerSolver.Game.set(game, 0, 1, 2)
    game = TowerSolver.Game.set(game, 4, 4, 5)
    game = TowerSolver.Game.set(game, 5, 2, 3)
    game = TowerSolver.Game.set(game, 5, 4, 1)
    solutions = TowerSolver.Game.solve(game)
    _ = Enum.map(solutions, fn x -> IO.puts("#{x}\n\n") end)
    IO.puts("Found #{length(solutions)} solutions")
  end
end
