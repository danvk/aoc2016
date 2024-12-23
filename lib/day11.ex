# https://adventofcode.com/2016/day/11
defmodule Day11 do
  alias ElixirSense.Core.Compiler.State

  @elements %{
    "hydrogen" => :H,
    "lithium" => :L,
    "polonium" => :Po,
    "thulium" => :T,
    "promethium" => :Pr,
    "ruthenium" => :R,
    "cobalt" => :Co
  }

  defmodule State do
    defstruct level: 1, items: %{}
  end

  defp parse_line(line) do
    @elements
    |> Enum.flat_map(fn {elem, sym} ->
      [
        if(String.contains?(line, "#{elem} generator"), do: {sym, :rtg}, else: nil),
        if(String.contains?(line, "#{elem}-compatible microchip"),
          do: {sym, :chip},
          else: nil
        )
      ]
    end)
    |> Enum.filter(&(&1 != nil))
  end

  def is_success(state) do
    Enum.all?(1..3 |> Enum.map(&Enum.empty?(state.items[&1])))
  end

  def is_fatal_level(items) do
    rtgs = for {el, :rtg} <- items, do: el, into: MapSet.new()

    if rtgs |> Enum.empty?() do
      false
    else
      for({el, :chip} <- items, do: !MapSet.member?(rtgs, el))
      |> Enum.any?()
    end
  end

  def is_fatal(state) do
    for(
      {_, items} <- state.items,
      do: is_fatal_level(items)
    )
    |> Enum.any?()
  end

  def move(state, new_level, items) do
    old_items = state.items[state.level]

    %State{
      level: new_level,
      items:
        state.items
        |> Map.put(
          state.level,
          old_items |> Enum.filter(&(!Enum.member?(items, &1))) |> Enum.sort()
        )
        |> Map.put(new_level, (Map.get(state.items, new_level) ++ items) |> Enum.sort())
    }
  end

  def nexts(state) do
    next_levels = [state.level - 1, state.level + 1] |> Enum.filter(&(&1 >= 1 && &1 <= 4))

    items = state.items[state.level]

    pairs =
      for({a, b} <- Util.pairs(items), do: [a, b])
      |> Enum.filter(fn
        [{a, :chip}, {b, :rtg}] when a != b -> false
        [{a, :rtg}, {b, :chip}] when a != b -> false
        [_, _] -> true
      end)

    singles = for item <- items, do: [item]
    possible_items = singles ++ pairs

    for(
      level <- next_levels,
      items <- possible_items,
      do: move(state, level, items)
    )
    |> Enum.reject(&is_fatal/1)
  end

  def neighbors(state) do
    for state <- nexts(state), do: {1, state}
  end

  def cost(state) do
    for({level, items} <- state.items, do: (4 - level) * Enum.count(items)) |> Enum.sum()
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file)

    if instrs |> Enum.count() != 4 do
      raise "Invalid input"
    end

    items =
      instrs
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, i} -> parse_line(line) |> Enum.map(&{i + 1, &1}) end)
      |> Enum.group_by(&Util.first/1, &Util.second/1)

    items = %{1 => [], 2 => [], 3 => [], 4 => []} |> Map.merge(items)
    init_state = %State{level: 1, items: items}

    final_state = %State{
      level: 1,
      items: %{1 => [], 2 => [], 3 => [], 4 => [{:H, :rtg}, {:H, :chip}]}
    }

    fatal_state = %State{
      level: 1,
      items: %{1 => [], 2 => [], 3 => [{:H, :chip}, {:Po, :rtg}], 4 => [{:H, :rtg}]}
    }

    IO.inspect(init_state)
    IO.inspect(is_success(final_state))
    IO.inspect(is_fatal(init_state))
    IO.inspect(is_fatal(final_state))
    IO.inspect(is_fatal(fatal_state))

    # IO.inspect(move(init_state, 2, []))

    # IO.inspect(nexts(init_state))
    IO.inspect(cost(init_state))
    IO.inspect(cost(final_state))

    {cost, _path} = Search.a_star([init_state], &is_success/1, &neighbors/1)
    # IO.inspect(Enum.zip(Enum.map(path, &cost/1), path))
    IO.inspect(cost)
  end
end
