defmodule Skillchecker.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Skillchecker.Repo
  use Skillchecker.AdminFactory
  use Skillchecker.SkillsetFactory
  use Skillchecker.ItemFactory
  use Skillchecker.GroupFactory
  use Skillchecker.CharacterFactory
end
