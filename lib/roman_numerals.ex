defmodule RomanNumerals do
  @moduledoc """
  Task definition: Create a function taking a positive integer as its parameter and
  returning a string containing the Roman Numeral representation of that integer.
  """

  @mappings [{"X", 10}, {"IX", 9}, {"V", 5}, {"IV", 4}, {"I", 1}]
  @decode [{"V", 5}, {"IV", 4}, {"III", 3}, {"II", 2}, {"I", 1}]

  def convert(number) do
    {0, str} =
      Enum.reduce(@mappings, {number, ""}, fn {roman, arabic}, {number, str} ->
        {rem(number, arabic), str <> String.duplicate(roman, div(number, arabic))}
      end)

    str
  end

  def to_num(string) do
    {_, num} = Enum.find(@decode, fn {k, _v} -> k == string |> String.upcase end)

    num
  end
end