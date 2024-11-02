defmodule Skillchecker.ItemFactory do
  @moduledoc false

  alias Skillchecker.Static.Item

  defmacro __using__(_opts) do
    quote do
      def item_factory do
        %Item{
          name: "some name",
          skill_multiplier: 5,
          skill_level: 1,
          eveid: 5
        }
      end
    end
  end
end
