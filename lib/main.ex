defmodule TowerSolver.CLI do
  @moduledoc """
  pass
  """
  @spec prep_game(
          integer(),
          TowerSolver.Constraints.t(),
          (integer() -> Board.t()),
          [[integer()]]
        ) :: TowerSolver.Game.t()
  def prep_game(size, constraints, board_type, board_state) do
    game = TowerSolver.Game.new(size, constraints, board_type)

    board =
      Enum.reduce(board_state, game.board, fn [r, c, s], b ->
        Board.set(b, r, c, s)
      end)

    %{game | :board => board}
  end

  def six_by_six_game() do
    size = 6

    constraints = %TowerSolver.Constraints{
      top: [2, 3, 1, 2, 3, 2],
      bottom: [2, 1, 4, 3, 3, 2],
      left: [2, 3, 3, 1, 5, 2],
      right: [2, 3, 2, 5, 1, 2]
    }

    board_state = [
      [0, 1, 2],
      [4, 4, 5],
      [5, 2, 3],
      [5, 4, 1]
    ]

    {size, constraints, board_state}
  end

  def seven_by_seven_game() do
    size = 7

    constraints = %TowerSolver.Constraints{
      top: [3,1,2,2,4,4,2],
      bottom: [3,4,2,3,2,1,3],
      left: [2,2,3,1,2,5,4],
      right: [3,1,3,3,4,2,2]
    }

    board_state = [
      [0, 0, 3],
      [2, 5, 5],
      [2, 6, 1],
      [4, 3, 3],
      [4, 5, 4],
      [6, 4, 3],
    ]

    {size, constraints, board_state}
  end

  def nine_by_nine_game() do
    # solution
    # 985732146
    # 842175693
    # 391467852
    # 564829731
    # 217396485
    # 129548367
    # 473681529
    # 736254918
    # 658913274
    size = 9

    constraints = %TowerSolver.Constraints{
      top: [1, 2, 3, 3, 3, 4, 4, 2, 3],
      bottom: [4, 3, 2, 1, 4, 4, 2, 3, 3],
      left: [1, 2, 2, 4, 3, 3, 4, 2, 3],
      right: [4, 2, 4, 4, 3, 3, 1, 2, 3]
    }

    board_state = [
      [0, 4, 3],
      [0, 5, 2],
      [1, 6, 6],
      [2, 3, 4],
      [2, 5, 7],
      [2, 7, 5],
      [2, 8, 2],
      [3, 1, 6],
      [4, 1, 1],
      [4, 5, 6],
      [4, 6, 4],
      [5, 3, 5],
      [5, 4, 4],
      [5, 7, 6],
      [6, 0, 4],
      [6, 2, 3],
      [6, 4, 8],
      [6, 6, 5],
      [7, 2, 6],
      [7, 4, 5]
    ]

    {size, constraints, board_state}
  end

  def main(_args \\ []) do
    {size, constraints, board_state} = seven_by_seven_game()

    tuple_game =
      prep_game(size, constraints, &TupleBoard.new/1, board_state)

    list_game =
      prep_game(size, constraints, &ListBoard.new/1, board_state)

    # solutions = TowerSolver.Game.solve(list_game)
    # _ = Enum.map(solutions, fn x -> IO.puts("#{x}\n\n") end)
    # IO.puts("Found #{length(solutions)} solutions")

    Benchee.run(%{
      "ListBoard" => fn -> TowerSolver.Game.solve(list_game) end,
      "TupleBoard" => fn -> TowerSolver.Game.solve(tuple_game) end
    })
  end
end
