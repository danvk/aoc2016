# https://adventofcode.com/2016/day/10
defmodule Day10 do
  defp bot_or_out("bot"), do: :bot
  defp bot_or_out("output"), do: :output

  defp parse_line(line) do
    # value 5 goes to bot 2
    # bot 2 gives low to bot 1 and high to bot 0
    # bot 0 gives low to output 2 and high to output 0
    m1 = Regex.run(~r"value (\d+) goes to bot (\d+)", line)

    m2 =
      Regex.run(
        ~r"bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)",
        line
      )

    case {m1, m2} do
      {[_, vs, bs], _} ->
        {:set, String.to_integer(vs), String.to_integer(bs)}

      {_, [_, bs, oblow, nlow, obhi, nhi]} ->
        {:give, String.to_integer(bs), {bot_or_out(oblow), String.to_integer(nlow)},
         {bot_or_out(obhi), String.to_integer(nhi)}}
    end
  end

  defp give(values, _bot, {:output, _target}, _num) do
    # IO.puts("#{bot} outputs #{num} to #{target}")
    values
  end

  defp give(values, _bot, {:bot, target}, num) do
    # IO.puts("#{bot} gives #{num} to #{target}")
    Map.put(values, target, [num | Map.get(values, target, [])])
  end

  defp loop(values, instrs) do
    two = values |> Enum.find(fn {_, vals} -> Enum.count(vals) == 2 end)

    case two do
      {bot, vals} ->
        [lo, hi] = vals |> Enum.sort()
        {lo_instr, hi_instr} = instrs[bot]

        if [lo, hi] == [2, 5] or [lo, hi] == [17, 61] do
          IO.puts("bot #{bot} compares #{lo} and #{hi}")
        end

        new_values =
          values |> give(bot, lo_instr, lo) |> give(bot, hi_instr, hi) |> Map.put(bot, [])

        loop(new_values, instrs)

      nil ->
        values
    end
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)

    gives = for {:give, bot, low, hi} <- instrs, into: %{}, do: {bot, {low, hi}}

    starts =
      for {:set, val, bot} <- instrs, reduce: %{} do
        acc -> Map.put(acc, bot, [val | Map.get(acc, bot, [])])
      end

    loop(starts, gives)
    # IO.inspect(final_values)
  end
end
