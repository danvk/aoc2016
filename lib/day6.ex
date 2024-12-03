# https://adventofcode.com/2016/day/6
defmodule Day6 do
  def parse_line(line) do
    String.split(line)
  end

  def most_freq(xs) do
    xs
    |> Enum.group_by(& &1)
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.sort(fn {_, a}, {_, b} -> b < a end)
    |> hd
    |> elem(0)
  end

  def main(input_file) do
    IO.puts(most_freq([1, 2, 3, 1]))

    counts =
      Util.read_lines(input_file)
      |> Enum.flat_map(fn line -> Enum.zip(0..String.length(line), String.to_charlist(line)) end)
      |> Enum.group_by(fn {i, _c} -> i end, fn {_i, c} -> c end)
      |> Enum.map(fn {i, cs} -> {i, most_freq(cs)} end)
      |> Enum.map(fn {_i, c} -> c end)

    IO.inspect(counts)
  end
end
