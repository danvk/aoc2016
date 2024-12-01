# https://adventofcode.com/2016/day/5
defmodule Day5 do
  def main(input_file) do
    door_id = Util.read_lines(input_file) |> hd |> String.split()

    interesting =
      Util.range_from(0)
      |> Stream.map(fn i ->
        :crypto.hash(:md5, "#{door_id}#{i}") |> Base.encode16(case: :lower)
      end)
      |> Stream.filter(&String.starts_with?(&1, "00000"))
      |> Enum.take(24)

    IO.inspect(interesting)
    IO.puts(interesting |> Enum.take(8) |> Enum.map(&String.at(&1, 5)) |> Enum.join())

    # interesting = [
    #   "00000155f8105dff7f56ee10fa9b9abd",
    #   "000008f82c5b3924a1ecbebf60344e00",
    #   "00000f9a2c309875e05c5a5d09f1b8c4",
    #   "000004e597bd77c5cd2133e9d885fe7e",
    #   "0000073848c9ff7a27ca2e942ac10a4c",
    #   "00000a9c311683dbbf122e9611a1c2d4",
    #   "000003c75169d14fdb31ec1593915cff",
    #   "0000000ea49fd3fc1b2f10e02d98ee96"
    # ]

    int2 =
      interesting
      |> Enum.map(fn hash -> {String.at(hash, 5), String.at(hash, 6)} end)
      |> Enum.filter(fn {pos, _} -> String.to_integer(pos, 16) < 8 end)
      |> Enum.uniq_by(fn {pos, _} -> pos end)
      |> Enum.sort()

    IO.inspect(int2)
    IO.puts(int2 |> Enum.count())
    IO.puts(int2 |> Enum.map(&elem(&1, 1)) |> Enum.join())
  end
end
