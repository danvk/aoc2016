# Advent of Code 2016

## Day 1

Setup was not difficult, `brew install elixir`.

It's convenient that Elixir has a scripting mode (`.exs`).
I installed the Elixir VS Code extension, but I'm not getting much from it. I think it requires a "mixfile" to understand my project.
I had the logic wrong on part 1 (walk then turn, not turn then walk), but still got the correct answer. Unclear whether that would have worked for part 2.

I don't love my solution to part 2. The nested `Enum.reduce_while` calls feel icky. I wonder if a more idiomatic way to do this would be with processes, to have one process send a message for each location you visit and the other wait for a repeat.

It's annoying that you can't interpolate an `{int, int}` tuple into a string:

```
iex(6)> tup = {1, 2}
{1, 2}
iex(7)> "hello #{tup}"
** (Protocol.UndefinedError) protocol String.Chars not implemented for {1, 2} of type Tuple
    (elixir 1.17.3) lib/string/chars.ex:3: String.Chars.impl_for!/1
    (elixir 1.17.3) lib/string/chars.ex:22: String.Chars.to_string/1
    iex:7: (file)
```

This is especially annoying since the syntax for indexing into tuples is so verbose (`elem(tup, 1)`).

All the pairs and triples you wind up forming for calls to reduce make me want a type system.

## Day 2

972899 is too high.
Problem was a trailing newline, which made me repeat the last entry.

TODO:

- [x] Fix the trailing newline bug
- [x] Make accumulate more efficient
- [x] Move accumulate into a library file
- [x] Make it work for both parts

I noticed `itertools.accumulate` recently and decided that was the function I wanted on day 1. Easy enough to implement.

Module constants in Elixir seem pretty weird. They're prefixed with `@`.

You match a character with `?A`, `?B`, etc.

I think GitHub copilot is familiar with previous year's Advent of Code, the autocomplete is rather surprisingly good.

I'm surprised how much ceremony there is to pass a function around in Elixir. `&Day2.apply_instrs/2` instead of just `apply_instrs`. I guess the `/2` helps with resolution, but why the `&`?

`&Day2.apply_instrs(&1, &2, 2)`: Is there shorthand for binding just the first or last argument of a function?

To move code into a `Common` module, I had to put it in `lib/common.ex` (not `lib/common.exs`) and compile it with `elixirc`:

    elixirc lib/common.ex

So now I have a build step.

It may be possible to use `Mix.install` instead: https://stackoverflow.com/a/75425548/388951

Language services are pretty crappy -- I'm not getting syntax errors, F2 rename variable or any type information. Unclear to me if this is expected or some kind of configuration error.

## Day 3

Not too bad. Part 2 was an annoying rearrangement of the input that makes it not purely line-oriented. Fortunately Elixir has `Enum.chunk` built-in.

You write the identify function `&(&1)`.

My `transpose` function is inefficient but simple. Generators are going to be handy. I thought I had a bug at first, but `IO.puts` renders `[100, 101, 102]` as a charlist, `~c"efg"`.

I continue to be puzzled that I don't get any kind of syntax guidance in VS Code. Aha! It seems to be a `.ex` vs. `.exs` difference.

https://elixirforum.com/t/vscode-elixirls-not-highlighting-exs-files/40239
https://github.com/elixir-lsp/elixir-ls/issues/89

Now I'm getting errors… but weird ones. It seems like the language service is actually running my code?

```
$ elixirc lib/day3.ex

== Compilation error in file lib/day3.ex ==
** (RuntimeError) Usage: day3.ex <input_file>
    lib/day3.ex:21: Day3.get_arg1/0
    lib/day3.ex:26: (file)
    (elixir 1.17.3) lib/kernel/parallel_compiler.ex:429: anonymous fn/5 in Kernel.ParallelCompiler.spawn_workers/8
```

https://elixirschool.com/en/lessons/intermediate/escripts

Aha again! All code must be inside `defmodule`. Now I get lots more information in my editor like `@spec` annotations on my functions. It looks like you can click these to fill in type annotations.

I'm able to run my script wiht `escript` using this sequence:

    mix escript.build
    ./day3 input/day3/input.txt

I don't love this, but I can work with it. It might be a good idea to look into how someone from r/adventofcode sets up their Elixir project.

https://github.com/mathsaey/adventofcode
https://github.com/mathsaey/advent_of_code_utils

He runs his code through `iex`.

## Day 4

I completely misread what the problem was asking for. It wanted the sum of the sector IDs, not the number of valid rooms.

After part 1, part 2 was more straightforward. In Elixir it's not `a % b`, it's `rem(a, b)`. There is a `String.contains?` function that was helpful for part 2.

## Day 5

https://elixirforum.com/t/is-it-possible-to-have-lazy-evaluation-on-list-comprehensions/48136/5
https://stackoverflow.com/questions/36134979/hash-md5-in-elixir

You call an Erlang function like this: `:crypto.hash`.
You can close a lazy stream by piping it into a greedy `Enum` method.

This takes ~6s to run. Building with MIX_ENV=prod doesn't make much of a difference. I assume all the time is spent inside `crypto.hash`.

There's no built-in way to do an unbounded range, but it's easy to implement:

```elixir
Stream.iterate(0, &(&1 + 1))
```

I wound up taking 24 "interesting" hashes for my input on part 2. A nice extension to this solution would lazily take only as many as needed.

## Day 6

What's the most idiomatic way to pull out the first item from a tuple?

```elixir
fn {a, _b} -> a end
&elem(&1, 0)
```

## Day 7

I used a state machine to split out the hypernet sequences and used an `Enum.zip` with four inputs to check for the ABBA pattern. I'm curious how a more experienced Elixirite might do this.

My bug was allowing a match like `ab[c]ba`.

## Day 8

How can I try matching a series of regular expressions?

## Day 9

Part 2 feels kinda hard for a day 9! It was kind of Eric to make the repeated sections not fall in the middle of a marker.

## Day 10

This one was kind of silly.

## Day 11

I'm having a lot of trouble with this one! There are ten items (five chips and five RTGs) that can be at one of four levels. The elevator can also be at one of four levels. So that should be 4^11 possible states, ~4M. That's not that much! Maybe my `neighbors` function is just incredibly slow?

Oh, maybe I should sort the lists for each floor!

Part 2: After 49 minutes, it output 83 which was incorrect. Maybe I should flood fill from both directions (start and end)? The step function is the same in both directions, so this should be a big win.

… or maybe not. I'm still really bogging down.

Is it safe to assume that you never move an RTG down? That would be a big constraint. Evidently not, that works for the sample but not for my input.

I feel like I'm missing something. This is way too hard.

I grabbed this solution:
https://github.com/hbldh/AdventOfCode/blob/master/AOC2016/11.py

My answer for part 2 is 71, so my code from yesterday must have missed a state. This solution took ~1 minute to run and looks like it takes the exact same approach as mine. So maybe my constant factors are just terrible.

His solution caches the `is_valid` calls. I guess that could help.

This one is even faster:
https://www.reddit.com/r/adventofcode/comments/5hoia9/2016_day_11_solutions/db1zbu0/

And I figured out my bug. It's so stupid! My hacky parsing code matched "Dilithium" as both "Lithium" _and_ "Dilithium". So I both made the problem harder than necessary, and gave myself a wrong answer.

In any case, I finally got the right answer and my code runs incredibly fast: 0.2s for part 1 and 3.2s for part 2.

I went back and ran my zero optimizations version with the correctly-parsed input (commit 712e136). Runs in 2s for part 1, 2 minutes for part 2. This definitely goes down in the annals of costly and ridiculous bugs!
