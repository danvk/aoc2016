# https://adventofcode.com/2016/day/7
defmodule Day7 do
  def parse_line(line) do
    String.split(line)
  end

  def split_hypernet(txt) do
    {in_chars, out_chars, _in_acc} =
      txt
      |> String.to_charlist()
      |> Enum.reduce(
        {~c"", ~c"", false},
        fn c, {in_chars, out_chars, in_acc} ->
          case {c, in_acc} do
            {?[, false} -> {in_chars, [?| | out_chars], true}
            {?], true} -> {in_chars, out_chars, false}
            {_c, true} -> {in_chars, [c | out_chars], true}
            {c, false} -> {[c | in_chars], out_chars, false}
          end
        end
      )

    {in_chars |> Enum.reverse(), out_chars |> Enum.reverse()}
  end

  def has_abba(txt) do
    match =
      Enum.zip([txt, txt |> Enum.drop(1), txt |> Enum.drop(2), txt |> Enum.drop(3)])
      |> Enum.find(fn {a, b, c, d} -> a == d && b == c && a != b end)

    match != nil
  end

  def supports_tls({in_chars, out_chars}) do
    has_abba(in_chars) && not has_abba(out_chars)
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&split_hypernet/1)
    # supports = Enum.zip(instrs, Enum.map(instrs, &supports_tls/1))
    # IO.inspect(supports)
    IO.puts(instrs |> Enum.filter(&supports_tls/1) |> Enum.count())
  end
end
