# https://adventofcode.com/2016/day/8
defmodule Day8 do
  def parse_line(line) do
    parts = line |> String.split()

    case parts do
      ["rect", dims] ->
        {:rect, Util.read_ints(dims, "x")}

      ["rotate", "column", colstr, "by", n] ->
        {:rotcol, colstr |> String.trim_leading("x=") |> String.to_integer(),
         n |> String.to_integer()}

      ["rotate", "row", rowstr, "by", n] ->
        {:rotrow, rowstr |> String.trim_leading("y=") |> String.to_integer(),
         n |> String.to_integer()}
    end
  end

  def rect(w, h) do
    for x <- 0..(w - 1), y <- 0..(h - 1), into: %{}, do: {{x, y}, ?#}
  end

  def rotcol(grid, {maxx, maxy}, cx, n) do
    for x <- 0..maxx,
        y <- 0..maxy,
        into: %{},
        do:
          (case x do
             ^cx -> {{x, y}, Map.get(grid, {x, Integer.mod(y - n, maxy + 1)})}
             _ -> {{x, y}, Map.get(grid, {x, y})}
           end)
  end

  def rotrow(grid, {maxx, maxy}, cy, n) do
    for x <- 0..maxx,
        y <- 0..maxy,
        into: %{},
        do:
          (case y do
             ^cy -> {{x, y}, Map.get(grid, {Integer.mod(x - n, maxx + 1), y})}
             _ -> {{x, y}, Map.get(grid, {x, y})}
           end)
  end

  def exec_instr(grid, dims, instr) do
    case instr do
      {:rect, [w, h]} -> Map.merge(grid, rect(w, h))
      {:rotcol, x, n} -> rotcol(grid, dims, x, n)
      {:rotrow, y, n} -> rotrow(grid, dims, y, n)
    end
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)
    # dims = {6, 2}
    dims = {49, 5}
    {maxw, maxh} = dims
    Util.inspect(instrs)

    grid = for x <- 0..maxw, y <- 0..maxh, into: %{}, do: {{x, y}, ?.}
    new_grid = instrs |> Enum.reduce(grid, &exec_instr(&2, dims, &1))
    Util.print_grid(new_grid, dims)
    IO.puts("part1: #{Enum.count(new_grid, fn {_k, v} -> v == ?# end)}")
  end
end
