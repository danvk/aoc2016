# https://adventofcode.com/2016/day/4
defmodule Day4 do
  def count_letters(str) do
    str
    |> String.to_charlist()
    |> Enum.filter(&(&1 >= ?a and &1 <= ?z))
    |> Enum.group_by(& &1)
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.sort(fn {k1, c1}, {k2, c2} -> c1 > c2 or (c1 == c2 and k1 < k2) end)
  end

  def parse_line(line) do
    [room, checksum] = String.split(line, ["[", "]"], trim: true)
    parts = String.split(room, "-", trim: true)
    sector = List.last(parts) |> String.to_integer()
    {room, checksum, sector}
  end

  def counts_to_checksum(checksum) do
    Enum.take(checksum, 5)
    |> Enum.map(fn {k, _} -> k end)
    |> List.to_string()
  end

  def shift_char(c, n) do
    case c do
      ?- -> ?\s
      _ -> ?a + rem(c - ?a + n, 26)
    end
  end

  def decrypt_room(room, sector_id) do
    room
    |> String.to_charlist()
    |> Enum.map(&shift_char(&1, sector_id))
    |> List.to_string()
  end

  def main(args) do
    input_file = hd(args)
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)
    IO.inspect(instrs)

    counts =
      Enum.map(instrs, fn {room, chk, sector} ->
        {counts_to_checksum(count_letters(room)), chk, sector}
      end)

    # IO.inspect(instrs |> Enum.at(2) |> elem(0))
    # IO.inspect(count_letters(instrs |> Enum.at(2) |> elem(0)))

    valids = Enum.filter(counts, fn {chk, chk2, _} -> chk == chk2 end)
    IO.puts(valids |> Enum.count())
    IO.puts(valids |> Enum.map(&elem(&1, 2)) |> Enum.sum())
    # IO.inspect(counts)

    decrypted =
      Enum.map(instrs, fn {room, _, sector} ->
        {decrypt_room(room, sector), sector}
      end)

    norths = Enum.filter(decrypted, fn {room, _} -> String.contains?(room, "north") end)

    IO.inspect(norths)
  end
end
