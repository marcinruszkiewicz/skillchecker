defmodule Mix.Tasks.Sde.Import do
  @moduledoc """
  Console task for importing the EVE SDE.
  """
  use Mix.Task

  @shortdoc "import EVE SDE yaml files from priv/"

  def run(_) do
    Mix.Task.run("app.start")

    Skillchecker.Repo.query("TRUNCATE static_groups", [])
    Skillchecker.Repo.query("TRUNCATE static_items", [])

    File.cwd!
    |> Path.join("priv/types.yaml.gz")
    |> File.read!
    |> :zlib.gunzip
    |> YamlElixir.read_from_string
    |> save_item_data

    File.cwd!
    |> Path.join("priv/groups.yaml.gz")
    |> File.read!
    |> :zlib.gunzip
    |> YamlElixir.read_from_string
    |> save_group_data
  end

  defp save_group_data({:error, %{message: reason}}), do: IO.puts reason
  defp save_group_data({:ok, items}) do
    Enum.each(items, fn({key, item}) ->
      attrs = %{
        name: item["name"]["en"],
        groupid: key
      }

      %Skillchecker.Static.Group{}
      |> Skillchecker.Static.Group.changeset(attrs)
      |> Skillchecker.Repo.insert
    end)
  end

  defp read_type_dogma do
    result = File.cwd!
      |> Path.join("priv/typeDogma.yaml.gz")
      |> File.read!
      |> :zlib.gunzip
      |> YamlElixir.read_from_string

    case result do
      {:ok, type_dogma} ->
        type_dogma
      {:error, %{message: _reason}} ->
        %{}
    end
  end

  defp save_item_data({:error, %{message: reason}}), do: IO.puts reason
  defp save_item_data({:ok, items}) do
    type_dogma = read_type_dogma()

    Enum.each(items, fn({key, item}) ->
      %{0 => level1, 1 => level2, 2 => level3, 3 => level4, 4 => level5} =
        case item["masteries"] do
          %{} ->
            item["masteries"]
          nil ->
            %{0 => [], 1 => [], 2 => [], 3 => [], 4 => []}
        end

      attrs = %{
        name: item["name"]["en"],
        eveid: key,
        mastery1: level1,
        mastery2: level2,
        mastery3: level3,
        mastery4: level4,
        mastery5: level5,
        groupid: item["groupID"]
      }

      data_from_dogma = extract_skill_data(type_dogma[key]["dogmaAttributes"])
      attrs = Map.merge attrs, data_from_dogma

      %Skillchecker.Static.Item{}
      |> Skillchecker.Static.Item.changeset(attrs)
      |> Skillchecker.Repo.insert
    end)
  end

  defp get_attribute_value(nil), do: nil
  defp get_attribute_value(map), do: Map.get(map, "value") |> Kernel.trunc

  defp get_skill_attribute(type_dogma_attributes, attributeID) do
    Enum.find(type_dogma_attributes, fn m -> m["attributeID"] == attributeID end) |> get_attribute_value
  end

  defp extract_skill_data(nil), do: %{}
  defp extract_skill_data(type_dogma_attributes) do
    if get_skill_attribute(type_dogma_attributes, 180) == nil do
      %{}
    else
      %{
        required_skill_1_id: get_skill_attribute(type_dogma_attributes, 182),
        required_skill_1_level: get_skill_attribute(type_dogma_attributes, 277),
        required_skill_2_id: get_skill_attribute(type_dogma_attributes, 183),
        required_skill_2_level: get_skill_attribute(type_dogma_attributes, 278),
        required_skill_3_id: get_skill_attribute(type_dogma_attributes, 184),
        required_skill_3_level: get_skill_attribute(type_dogma_attributes, 279),
        required_skill_4_id: get_skill_attribute(type_dogma_attributes, 1285),
        required_skill_4_level: get_skill_attribute(type_dogma_attributes, 1286),
        required_skill_5_id: get_skill_attribute(type_dogma_attributes, 1289),
        required_skill_5_level: get_skill_attribute(type_dogma_attributes, 1287),
        required_skill_6_id: get_skill_attribute(type_dogma_attributes, 1290),
        required_skill_6_level: get_skill_attribute(type_dogma_attributes, 1288),
        primary_attribute_id: get_skill_attribute(type_dogma_attributes, 180),
        secondary_attribute_id: get_skill_attribute(type_dogma_attributes, 181),
        skill_multiplier: get_skill_attribute(type_dogma_attributes, 275),
        skill_level: get_skill_attribute(type_dogma_attributes, 280),
        omega_only: get_skill_attribute(type_dogma_attributes, 1047)
      }
    end
  end
end