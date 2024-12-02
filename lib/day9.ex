# https://adventofcode.com/2016/day/9
defmodule Day9 do
  def parse_line(line) do
    String.split(line)
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)
    IO.inspect(instrs)
  end
end
