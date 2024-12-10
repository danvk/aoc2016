defmodule Util do
  def accumulate(xs, f, acc) do
    {_, seq} =
      Enum.reduce(xs, {acc, []}, fn x, {acc, accs} ->
        new_acc = f.(x, acc)
        {new_acc, [new_acc | accs]}
      end)

    Enum.reverse(seq)
  end

  def read_lines(file) do
    File.read!(file) |> String.trim_trailing() |> String.split("\n")
  end

  def pos_str(pos) do
    "#{elem(pos, 0)},#{elem(pos, 1)}"
  end

  def range_from(n) do
    Stream.iterate(n, &(&1 + 1))
  end

  def first({a, _b}) do
    a
  end

  def first([a, _b]) do
    a
  end

  def second({_a, b}) do
    b
  end

  def second([_a, b]) do
    b
  end

  def inspect(x) do
    IO.inspect(x, charlists: false)
  end

  def inspect(a, b) do
    IO.inspect({a, b}, charlists: false)
  end

  def read_ints(txt, delim) do
    txt |> String.split(delim) |> Enum.map(&String.to_integer/1)
  end

  def print_grid(grid, {w, h}) do
    for y <- 0..h do
      for x <- 0..w do
        IO.write([Map.get(grid, {x, y}, ?.)])
      end

      IO.puts("")
    end
  end
end
