# https://adventofcode.com/2016/day/23
defmodule Day23 do
  def parse_line(line) do
    String.split(line)
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)
    IO.inspect(instrs)
  end
end