# https://adventofcode.com/2016/day/5
defmodule Day5 do
  def parse_line(line) do
    String.split(line)
  end

  def main(input_file) do
    door_id = Util.read_lines(input_file) |> hd |> parse_line()

    nums =
      0..100_000_000
      |> Stream.map(fn i ->
        :crypto.hash(:md5, "#{door_id}#{i}") |> Base.encode16(case: :lower)
      end)
      |> Stream.filter(&String.starts_with?(&1, "00000"))
      |> Enum.take(8)

    IO.inspect(nums)
    IO.puts(nums |> Enum.map(&String.at(&1, 5)) |> Enum.join())
  end
end
