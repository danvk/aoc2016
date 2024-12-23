# https://adventofcode.com/2016/day/12
defmodule Day12 do
  def parse_line(line) do
    String.split(line)
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)
    IO.inspect(instrs)

    IO.inspect(Util.pairs([]))
    IO.puts("---")
    IO.inspect(Util.pairs([1]))
    IO.puts("---")
    IO.inspect(Util.pairs([1, 2]))
    IO.puts("---")
    IO.inspect(Util.pairs([1, 2, 3]))
    IO.puts("---")
    IO.inspect(Util.pairs([1, 2, 3, 4]))
  end
end
