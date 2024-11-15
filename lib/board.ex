defprotocol Board do
  @type t() :: t()
  # TODO: Build it with list, tuple, something else?!? to benchmark
  # Whatever type used needs to implement enumerable
  # Also need to either get `List.replace_at` for whatever type, or change this to something
  # more generic
  @spec rows(t) :: Enumerable.t(Enumerable.t(integer()))
  def rows(board)

  @spec cols(t) :: Enumerable.t(Enumerable.t(integer()))
  def cols(board)

  @spec set_row(t, integer(), [integer()]) :: t
  def set_row(board, row_num, row)

  @spec set(t, integer(), integer(), integer()) :: t
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
  def rows(board) do
    board.board
  end

  def cols(board) do
    Enum.zip_with(board.board, &Function.identity/1)
  end

  def set_row(board, row_num, row) do
    {_, snd} = Enum.split(board.board, row_num + 1)
    fst = Enum.take(board.board, row_num)
    %ListBoard{board: Enum.concat([fst, [row], snd])}
  end

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

defmodule TupleBoard do
  @moduledoc """
  TODO
  """
  @type t :: %__MODULE__{
          board: {{integer()}}
        }
  defstruct [:board]

  @spec new(integer()) :: TupleBoard.t()
  def new(size) do
    inner_tuple = Tuple.duplicate(0, size)

    %TupleBoard{
      board: Tuple.duplicate(inner_tuple, size)
    }
  end
end

defimpl Board, for: TupleBoard do
  def rows(board) do
    Tuple.to_list(board.board) |> Enum.map(&Tuple.to_list/1)
  end

  def cols(board) do
    size = tuple_size(board.board) - 1

    for i <- 0..size do
      for j <- 0..size do
        elem(elem(board.board, j), i)
      end
    end
  end

  def set_row(board, row_num, row) do
    %TupleBoard{board: put_elem(board.board, row_num, List.to_tuple(row))}
  end

  def set(board, row, col, value) do
    %TupleBoard{
      board:
        put_elem(
          board.board,
          row,
          put_elem(elem(board.board, row), col, value)
        )
    }
  end
end
