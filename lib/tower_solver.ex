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
    @type t :: %__MODULE__{
            size: integer,
            constraints: TowerSolver.Constraints.t(),
            board: [[integer]]
          }
    @enforce_keys [:size, :constraints, :board]
    defstruct [:size, :constraints, :board]

    @spec new(integer, TowerSolver.Constraints.t()) :: Game.t()
    def new(size, constraints) do
      %Game{
        size: size,
        constraints: constraints,
        board:
          for _ <- 1..size do
            for _ <- 1..size do
              0
            end
          end
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
          (Enum.zip([term.constraints.left, term.board, term.constraints.right])
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

    @spec rows(Game.t()) :: [[integer()]]
    defp rows(game) do
      game.board
    end

    @spec cols(Game.t()) :: [[integer()]]
    defp cols(game) do
      Enum.zip_with(game.board, &Function.identity/1)
    end

    @spec valid?(Game.t()) :: boolean()
    def valid?(game) do
      rows = rows(game)
      cols = cols(game)

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
             |> Enum.map(&has_duplicates?/1)
             |> Enum.any?())
    end

    # TODO: make this and others private
    @spec has_duplicates?([integer()]) :: boolean()
    def has_duplicates?(list) do
      Enum.uniq(list) != list
    end

    @spec valid_line?([any()]) :: boolean()
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

    @spec set_row(Game.t(), integer(), [integer()]) :: Game.t()
    def set_row(game, row_num, row) do
      {_, snd} = Enum.split(game.board, row_num + 1)
      fst = Enum.take(game.board, row_num)
      %Game{game | board: Enum.concat([fst, [row], snd])}
    end

    @spec set(Game.t(), integer(), integer(), integer()) :: Game.t()
    def set(game, row, col, value) do
      board = game.board

      board =
        List.replace_at(
          board,
          row,
          List.replace_at(Enum.at(board, row), col, value)
        )

      %{game | :board => board}
    end

    def fits_preset?(row, proposed_row) do
      Enum.zip(row, proposed_row)
      |> Enum.map(fn {x, y} -> x == 0 or x == y end)
      |> Enum.all?()
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
        valid_line?(p, {c1, c2}) and fits_preset?(Enum.at(game.board, step), p)
      end)
      |> Kernel.then(fn filtered_permus ->
        # Update progress bar
        Progress.add_total(agent, length(filtered_permus))
        {done, total} = Progress.get(agent)
        ProgressBar.render(done, total, suffix: :count)
        filtered_permus
      end)
      |> Enum.flat_map(fn p ->
        updated_game = set_row(game, step, p)
        cols = cols(updated_game)

        if should_continue_step?(cols) do
          Progress.add_done(agent)
          []
        else
          solve_step(updated_game, step + 1, permus, agent)
        end
      end)
    end

    defp should_continue_step?(cols) do
      Enum.map(cols, fn c ->
        Enum.filter(
          c,
          fn x -> x != 0 end
        )
      end)
      |> Enum.map(&has_duplicates?/1)
      |> Enum.any?()
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
end

# TODO: Build it with list, tuple, something else?!? to benchmark
