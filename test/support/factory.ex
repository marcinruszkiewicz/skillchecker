defmodule Skillchecker.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Skillchecker.Repo
  use Skillchecker.AdminFactory
end
