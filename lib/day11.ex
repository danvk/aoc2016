# https://adventofcode.com/2016/day/11
defmodule Day11 do
  @elements %{
    "hydrogen" => :H,
    "lithium" => :L,
    "polonium" => :Po,
    "thulium" => :T,
    "promethium" => :Pr,
    "ruthenium" => :R,
    "cobalt" => :Co,
    "elerium" => :E,
    "dilithium" => :D
  }
  @el_to_idx %{
    :Po => 1,
    :T => 2,
    :Pr => 3,
    :R => 4,
    :Co => 5,
    :E => 6,
    :D => 7
  }

  defmodule State do
    defstruct level: 1, items: %{}
  end

  defp parse_line(line) do
    @elements
    |> Enum.flat_map(fn {elem, sym} ->
      [
        if(String.contains?(line, " #{elem} generator"), do: {sym, :rtg}, else: nil),
        if(String.contains?(line, " #{elem}-compatible microchip"),
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

  defp is_fatal_level([]), do: false

  defp is_fatal_level(items) do
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
    level = state.level

    next_levels =
      cond do
        state.level == 2 and Enum.empty?(state.items[1]) -> [3]
        state.level == 3 and Enum.empty?(state.items[1]) and Enum.empty?(state.items[2]) -> [4]
        state.level == 1 -> [2]
        state.level == 4 -> [3]
        true -> [level - 1, level + 1]
      end

    items = state.items[level]

    pairs =
      for({a, b} <- Util.pairs(items), do: [a, b])

    pairs_up =
      for(
        level when level > state.level <- next_levels,
        items <- pairs,
        do: {level, items}
      )
      |> Enum.map(fn {level, items} -> move(state, level, items) end)
      |> Enum.reject(&is_fatal/1)

    pairs_down =
      for(
        level when level < state.level <- next_levels,
        items <- pairs,
        do: {level, items}
      )
      |> Enum.map(fn {level, items} -> move(state, level, items) end)
      |> Enum.reject(&is_fatal/1)

    singles = for item <- items, do: [item]

    singles_up =
      for(
        level when level > state.level <- next_levels,
        items <- singles,
        do: {level, items}
      )
      |> Enum.map(fn {level, items} -> move(state, level, items) end)
      |> Enum.reject(&is_fatal/1)

    singles_down =
      for(
        level when level < state.level <- next_levels,
        items <- singles,
        do: {level, items}
      )
      |> Enum.map(fn {level, items} -> move(state, level, items) end)
      |> Enum.reject(&is_fatal/1)

    # If you can move two items upstairs, don't bother bringing one item upstairs.
    # If you can move one item downstairs, don't bother bringing two items downstairs.
    if(Enum.empty?(pairs_up), do: singles_up, else: pairs_up) ++
      if Enum.empty?(singles_down), do: pairs_down, else: singles_down
  end

  def neighbors(state) do
    for state <- nexts(state), do: {1, state}
  end

  def cost(state) do
    for({level, items} <- state.items, do: (4 - level) * Enum.count(items)) |> Enum.sum()
  end

  # Expand in both directions from start to finish until they connect.
  # Returns d
  def bidirectional_search(start, finish, neighbors_fn) do
    bidi(0, MapSet.new([start]), MapSet.new([finish]), neighbors_fn, MapSet.new())
  end

  defp bidi(n, starts, finishes, n_fn, garbage) do
    IO.puts("n=#{n}, a=#{MapSet.size(starts)}, b=#{MapSet.size(finishes)}")

    if intersects(starts, finishes) do
      n
    else
      next_starts =
        for(n <- starts, next <- n_fn.(n), into: MapSet.new(), do: next)
        |> MapSet.difference(starts)

      new_garbage = MapSet.union(garbage, starts)
      bidi(n + 1, finishes, next_starts, n_fn, new_garbage)
    end
  end

  defp intersects(a, b) do
    if MapSet.size(a) <= MapSet.size(b) do
      a |> Enum.find(fn n -> MapSet.member?(b, n) end) != nil
    else
      intersects(b, a)
    end
  end

  defp make_target(state) do
    items = for(items <- Map.values(state.items), item <- items, do: item) |> Enum.sort()

    %State{
      level: 4,
      items: %{
        1 => [],
        2 => [],
        3 => [],
        4 => items
      }
    }
  end

  def cache_key(state) do
    items =
      for(
        {level, items} <- state.items,
        item <- items,
        do: {level, item}
      )
      |> Enum.sort()

    items
    |> Enum.each(fn {_, {sym, _}} ->
      unless Map.get(@el_to_idx, sym) do
        raise("Missing #{sym}")
      end
    end)

    {_, _, out} =
      for {level, {sym, type}} <- items, reduce: {1, %{}, []} do
        {n, map, out} ->
          {map, k, n} =
            if Map.get(map, sym) do
              {map, Map.get(map, sym), n}
            else
              {Map.put(map, sym, n), n, n + 1}
            end

          {n, map, [{level, k, type} | out]}
      end

    {state.level, out |> Enum.sort()}
  end

  def state_to_str(state) do
    items = state.items

    items_list =
      1..4
      |> Enum.map(fn n ->
        items[n]
        |> Enum.map(fn
          {sym, :rtg} -> @el_to_idx[sym]
          {sym, :chip} -> -@el_to_idx[sym]
        end)
        |> Enum.sort()
      end)

    {state.level, items_list}
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

    # final_state = %State{
    #   level: 1,
    #   items: %{1 => [], 2 => [], 3 => [], 4 => [{:H, :rtg}, {:H, :chip}]}
    # }
    # fatal_state = %State{
    #   level: 1,
    #   items: %{1 => [], 2 => [], 3 => [{:H, :chip}, {:Po, :rtg}], 4 => [{:H, :rtg}]}
    # }

    IO.inspect(init_state)
    final_state = make_target(init_state)
    IO.puts("init:")
    IO.inspect(init_state)
    IO.inspect(cache_key(init_state))

    IO.puts("target:")
    IO.inspect(final_state)
    IO.inspect(cache_key(final_state))
    # IO.inspect(is_success(final_state))
    # IO.inspect(is_fatal(init_state))
    # IO.inspect(is_fatal(final_state))
    # IO.inspect(is_fatal(fatal_state))

    # IO.inspect(move(init_state, 2, []))

    # IO.inspect(nexts(init_state))
    # IO.inspect(cost(init_state))
    # IO.inspect(cost(final_state))

    {cost, path} = Search.a_star([init_state], &is_success/1, &neighbors/1, &cache_key/1)
    # IO.inspect(Enum.zip(Enum.map(path, &cost/1), path))
    # cost = bidirectional_search(init_state, final_state, &nexts/1)
    # IO.inspect(path)
    path |> Enum.each(fn state -> IO.inspect(state_to_str(state)) end)
    IO.inspect(cost)
  end
end
