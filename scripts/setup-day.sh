#!/usr/bin/env bash

# Sets $header
. scripts/cookie.sh

day=$1
dir=input/day$day
mkdir $dir
ex_file=lib/day$day.ex
url="https://adventofcode.com/2016/day/$day"
cat <<END > $ex_file
# $url
defmodule Day$day do
  def parse_line(line) do
    String.split(line)
  end

  def main(input_file) do
    instrs = Util.read_lines(input_file) |> Enum.map(&parse_line/1)
    IO.inspect(instrs)
  end
end
END

perl -i -pe '/next day here/ and print "      '$day' -> Day'$day'.main(file)\n"' lib/main.ex

# https://adventofcode.com/2016/day/3/input
curl "https://adventofcode.com/2016/day/$day/input" \
  --silent \
  -H "$header" \
  > $dir/input.txt

echo 'input:'
head $dir/input.txt

# https://adventofcode.com/2016/day/4
curl "$url" \
  --silent \
  -H "$header" \
  > $dir/day$day.html

./scripts/extract-sample.ts $dir/day$day.html $dir

echo ''
echo "mix escript.build && ./main $day $dir/input.txt"
echo ''
echo "https://adventofcode.com/2016/day/$day"
echo ''
