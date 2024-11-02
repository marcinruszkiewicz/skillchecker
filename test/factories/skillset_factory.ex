defmodule Skillchecker.SkillsetFactory do
  @moduledoc false

  alias Skillchecker.Skillsets.Skillset

  defmacro __using__(_opts) do
    quote do
      def skillset_factory do
        %Skillset{
          name: "L Combat",
          skill_list: "Amarr Battleship V\nCaldari Battleship V"
        }
      end
    end
  end
end
