# https://adventofcode.com/2016/day/9
defmodule Day9 do
  defp repeat(_, 0), do: []
  defp repeat(xs, n), do: xs ++ repeat(xs, n - 1)

  defp decompress([]), do: []

  defp decompress([?( | rest]) do
    # find the next ?)
    {marker, [?) | rest]} = Enum.split_while(rest, &(&1 != ?)))
    # IO.inspect(marker)
    # IO.inspect(rest)
    [len, rep] = marker |> to_string() |> Util.read_ints("x")
    {to_repeat, remainder} = rest |> Enum.split(len)
    repeat(to_repeat, rep) ++ decompress(remainder)
  end

  defp decompress([head | tail]), do: [head | decompress(tail)]

  defp decompress2([]), do: []

  defp decompress2([?( | rest]) do
    # find the next ?)
    {marker, [?) | rest]} = Enum.split_while(rest, &(&1 != ?)))
    # IO.inspect(marker)
    # IO.inspect(rest)
    [len, rep] = marker |> to_string() |> Util.read_ints("x")
    {to_repeat, remainder} = rest |> Enum.split(len)
    repeat(decompress2(to_repeat), rep) ++ decompress2(remainder)
  end

  defp decompress2([head | tail]), do: [head | decompress2(tail)]

  def main(input_file) do
    input_lines =
      Util.read_lines(input_file) |> Enum.map(&String.to_charlist/1)

    expanded1 = input_lines |> Enum.map(&decompress/1)
    # IO.inspect(lines)
    part1 = expanded1 |> Enum.map(&Enum.count(&1)) |> Enum.sum()
    IO.puts("part 1: #{part1}")

    expanded2 = input_lines |> Enum.map(&decompress2/1) |> Enum.map(&Enum.count(&1))
    IO.inspect(Enum.zip(input_lines, expanded2))
  end
end
