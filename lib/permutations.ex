defmodule Permutations do
  @moduledoc """
  Module to compute permutations of a list
  """
  def permutate([]) do
    []
  end

  def permutate([head]) do
    [[head]]
  end

  def permutate([head | tail]) do
    t = permutate(tail)

    Enum.flat_map(t, fn x -> insert_everywhere(head, x) end)
  end

  defp insert_everywhere(val, list) do
    for n <- 0..length(list) do
      List.insert_at(list, n, val)
    end
  end
end
