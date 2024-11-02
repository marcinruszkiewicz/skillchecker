defmodule Skillchecker.CharacterFactory do
  @moduledoc false

  alias Skillchecker.Characters.Character

  defmacro __using__(_opts) do
    quote do
      def character_factory do
        %Character{
          accepted: true,
          eveid: 42,
          name: sequence("Test Goon"),
          owner_hash: sequence("42zxc"),
          data: %{corporation: "Testwaffe", alliance: "GSF"}
        }
      end

      def character_with_skills_factory do
        %Character{
          accepted: true,
          eveid: 42,
          name: sequence("Test Goon"),
          owner_hash: sequence("42zxc"),
          data: %{corporation: "Testwaffe", alliance: "GSF"},
          skill_queue: [%{skill_id: 42, name: "Test Skill 1"}],
          skills: [%{skill_id: 60, name: "Test Skill 2", trained_level: 1}]
        }
      end
    end
  end
end
