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
        List.replace_at(
          board.board,
          row,
          List.replace_at(Enum.at(board.board, row), col, value)
        )
    }
  end
end
