defmodule TowerSolver do
  @moduledoc """
  Documentation for `TowerSolver`.
  """

  defmodule Progress do
    @moduledoc """
    pass
    """
    def add_done(agent) do
      Agent.update(agent, fn {done, total} -> {done + 1, total} end)
    end

    def add_total(agent, n) do
      Agent.update(agent, fn {done, total} -> {done, total + n} end)
    end

    def render(agent) do
      {done, total} = Progress.get(agent)
      ProgressBar.render(done, total, suffix: :count)
    end

    def init() do
      {:ok, agent} = Agent.start_link(fn -> {0, 1} end)
      agent
    end

    def get(agent) do
      Agent.get(agent, &Function.identity/1)
    end
  end

  defmodule Constraints do
    @moduledoc """
    Documentation for `Constraints`.
    """
    @type t :: %__MODULE__{
            top: [integer],
            bottom: [integer],
            left: [integer],
            right: [integer]
          }
    @enforce_keys [:top, :bottom, :left, :right]
    defstruct [:top, :bottom, :left, :right]

    defimpl String.Chars, for: Constraints do
      @spec to_string(Constraints.t()) :: String.t()
      def to_string(term) do
        "#{term.top |> inspect(charlists: :as_lists)}\n" <>
          "#{term.bottom |> inspect(charlists: :as_lists)}\n" <>
          "#{term.left |> inspect(charlists: :as_lists)}\n" <>
          "#{term.right |> inspect(charlists: :as_lists)}"
      end
    end
  end

  defmodule Game do
    @moduledoc """
    Documentation for `Game`.
    """
    alias TowerSolver.ListBoard
    alias TowerSolver.Board
    alias TowerSolver.ReplaceAtAble

    @type t :: %__MODULE__{
            size: integer(),
            constraints: TowerSolver.Constraints.t(),
            board: Board.t()
          }
    @enforce_keys [:size, :constraints, :board]
    defstruct [:size, :constraints, :board]

    @spec new(integer(), TowerSolver.Constraints.t()) :: Game.t()
    def new(size, constraints) do
      %Game{
        size: size,
        constraints: constraints,
        board: ListBoard.new(size)
      }
    end

    defimpl String.Chars, for: Game do
      @spec to_string(Game.t()) :: String.t()
      def to_string(term) do
        horizontal_line = String.duplicate("=", 5 + 2 * term.size)
        board_line = fn {l, b, r} -> "#{l}| #{Enum.join(b, " ")} |#{r}" end

        " | #{Enum.join(term.constraints.top, " ")} |" <>
          "\n" <>
          horizontal_line <>
          "\n" <>
          (Enum.zip([
             term.constraints.left,
             term.board.board,
             term.constraints.right
           ])
           |> Enum.map_join("\n", board_line)) <>
          "\n" <>
          horizontal_line <>
          "\n" <>
          " | #{Enum.join(term.constraints.bottom, " ")} |\n"
      end
    end

    @spec inversion_acc(integer, {integer, integer}) :: {integer, integer}
    defp inversion_acc(x, {cnt, prv_max} = acc) do
      if prv_max < x do
        {cnt + 1, x}
      else
        acc
      end
    end

    @spec valid?(Game.t()) :: boolean()
    def valid?(game) do
      rows = Board.rows(game.board)
      cols = Board.cols(game.board)

      Enum.zip_with(
        [
          rows,
          game.constraints.left,
          game.constraints.right
        ],
        &valid_line?/1
      )
      |> Enum.all?() and
        Enum.zip_with(
          [
            cols,
            game.constraints.top,
            game.constraints.bottom
          ],
          &valid_line?/1
        )
        |> Enum.all?() and
        not (Enum.concat(rows, cols)
             |> Enum.any?(&has_duplicates?/1))
    end

    # TODO: make this and others private
    @spec has_duplicates?([integer()]) :: boolean()
    def has_duplicates?(list) do
      Enum.uniq(list) != list
    end

    @spec valid_line?([any(), ...]) :: boolean()
    def valid_line?([list, fst, snd]) do
      valid_line?(list, fst) && valid_line?(Enum.reverse(list), snd)
    end

    @spec valid_line?([integer], {integer, integer}) :: boolean()
    def valid_line?(list, {fst, snd} = _constraint) do
      valid_line?(list, fst) && valid_line?(Enum.reverse(list), snd)
    end

    @spec valid_line?([integer], integer) :: boolean()
    def valid_line?(list, constraint) do
      {cnt, _} =
        Enum.reduce(list, {0, 0}, fn acc, x -> inversion_acc(acc, x) end)

      cnt == constraint
    end

    def fits_preset?(row, proposed_row) do
      Enum.zip(row, proposed_row)
      |> Enum.all?(fn {x, y} -> x == 0 or x == y end)
    end

    @spec solve(Game.t()) :: [Game.t()]
    def solve(game) do
      agent = Progress.init()
      permus = Permutations.permutate(for x <- 1..game.size, do: x)
      solve_step(game, 0, permus, agent)
    end

    def solve_step(game, step, _, agent) when step == game.size do
      Progress.add_done(agent)

      if valid?(game) do
        [game]
      else
        []
      end
    end

    def solve_step(game, step, permus, agent) do
      c1 = Enum.at(game.constraints.left, step)
      c2 = Enum.at(game.constraints.right, step)

      Enum.filter(permus, fn p ->
        valid_line?(p, {c1, c2}) and
          fits_preset?(Enum.at(game.board.board, step), p)
      end)
      |> Kernel.tap(fn filtered_permus ->
        # Update progress bar
        Progress.add_total(agent, length(filtered_permus))
        Progress.render(agent)
      end)
      |> Enum.flat_map(fn p ->
        updated_game = %{game | :board => Board.set_row(game.board, step, p)}

        cols = Board.cols(updated_game.board)

        if should_abort_step?(cols) do
          Progress.add_done(agent)
          []
        else
          solve_step(updated_game, step + 1, permus, agent)
        end
      end)
    end

    defp should_abort_step?(cols) do
      Enum.map(cols, fn c ->
        Enum.filter(
          c,
          fn x -> x != 0 end
        )
      end)
      |> Enum.any?(&has_duplicates?/1)
    end

    def example() do
      Game.new(3, %TowerSolver.Constraints{
        top: [3, 2, 1],
        bottom: [1, 2, 2],
        left: [3, 2, 1],
        right: [1, 2, 2]
      })
    end

    def example(size) do
      replicate = fn x -> for _ <- 1..size, do: x end

      Game.new(size, %TowerSolver.Constraints{
        top: replicate.(1),
        bottom: replicate.(2),
        left: replicate.(3),
        right: replicate.(4)
      })
    end
  end

  defprotocol ReplaceAtAble do
    @type t() :: term()

    @spec replace_at(ReplaceAtAble.t(), integer(), any()) :: ReplaceAtAble.t()
    def replace_at(collection, index, value)
  end

  defimpl ReplaceAtAble, for: List do
    def replace_at(collection, index, value) do
      List.replace_at(collection, index, value)
    end
  end

  defprotocol Board do
    @type t() :: t()
    # TODO: Build it with list, tuple, something else?!? to benchmark
    # Whatever type used needs to implement enumerable
    # Also need to either get `List.replace_at` for whatever type, or change this to something
    # more generic
    @spec rows(t) :: Enum.t()
    def rows(board)

    @spec cols(t) :: Enum.t()
    def cols(board)

    @spec set_row(Board.t(), integer(), [integer()]) :: Board.t()
    def set_row(board, row_num, row)

    @spec set(Board.t(), integer(), integer(), integer()) :: Board.t()
    def set(board, row, col, value)
  end

  defmodule ListBoard do
    @moduledoc """
    TODO
    """
    @type t :: %__MODULE__{
            board: [[integer()]]
          }
    defstruct [:board]

    @spec new(integer()) :: ListBoard.t()
    def new(size) do
      %ListBoard{
        board:
          for _ <- 1..size do
            for _ <- 1..size do
              0
            end
          end
      }
    end
  end

  defimpl Board, for: ListBoard do
    @spec rows(ListBoard) :: Enum.t()
    def rows(board) do
      board.board
    end

    @spec cols(ListBoard) :: Enum.t()
    def cols(board) do
      Enum.zip_with(board.board, &Function.identity/1)
    end

    @spec set_row(ListBoard, integer(), [integer()]) :: Board.t()
    def set_row(board, row_num, row) do
      {_, snd} = Enum.split(board.board, row_num + 1)
      fst = Enum.take(board.board, row_num)
      %ListBoard{board: Enum.concat([fst, [row], snd])}
    end

    @spec set(ListBoard, integer(), integer(), integer()) :: Board.t()
    def set(board, row, col, value) do
      %ListBoard{
        board:
          ReplaceAtAble.replace_at(
            board.board,
            row,
            ReplaceAtAble.replace_at(Enum.at(board.board, row), col, value)
          )
      }
    end
  end
end
