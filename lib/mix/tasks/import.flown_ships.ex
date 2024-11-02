defmodule Mix.Tasks.Import.FlownShips do
  @shortdoc "import flown ships from google sheets"

  @moduledoc """
  Console task for importing the ship data.
  """
  use Mix.Task

  alias GoogleApi.Sheets.V4.Api.Spreadsheets

  def run(_) do
    Mix.Task.run("app.start")

    Skillchecker.Repo.query("TRUNCATE flown_ships", [])

    # setup json key in ~/.config/gcloud/application_default_credentials.json
    practice_tracker_id = "132d74izUpPYoaIDxZPLrX08ARMYT6P8HOcWN0M5K0HA"

    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")
    conn = GoogleApi.Sheets.V4.Connection.new(token.token)

    {:ok, response} = Spreadsheets.sheets_spreadsheets_get(conn, practice_tracker_id)

    response.sheets
    |> get_practice_names()
    |> Enum.each(fn name ->
      name
      |> get_ship_data(conn, practice_tracker_id)
      |> Enum.each(fn att ->
        Skillchecker.Repo.insert!(att)
      end)
    end)
  end

  defp get_practice_names(sheets) do
    sheets
    |> Enum.map(fn sheet -> sheet.properties.title end)
    |> Enum.reject(fn title -> String.starts_with?(title, "!") end)
  end

  defp practice_ship_assignments_range(sheet_name), do: "'#{sheet_name}'!E2:G"

  defp practice_date(sheet_name) do
    sheet_name
    |> String.split(" -")
    |> List.first()
    |> Timex.parse!("{D} {Mfull}")
    |> Timex.set(year: 2024)
    |> Timex.to_date()
  end

  defp get_ship_data(sheet_name, conn, practice_tracker_id) do
    range = practice_ship_assignments_range(sheet_name)

    {:ok, response} =
      Spreadsheets.sheets_spreadsheets_values_get(conn, practice_tracker_id, range)

    response.values
    |> Enum.reject(&Enum.empty?/1)
    |> Enum.reject(fn row -> List.first(row) == "" end)
    |> Enum.reject(fn row -> List.first(row) == "Our Ships" end)
    |> Enum.reject(fn row -> Enum.count(row) == 1 end)
    |> Enum.map(fn row ->
      Enum.reject(row, fn field -> field == "" end)
    end)
    |> Enum.map(fn row ->
      if Enum.count(row) == 2 do
        stat_record(row, sheet_name)
      else
        [
          stat_record([Enum.at(row, 0), Enum.at(row, 1)], sheet_name),
          stat_record([Enum.at(row, 0), Enum.at(row, 2)], sheet_name)
        ]
      end
    end)
    |> List.flatten()
  end

  defp stat_record(row, sheet_name) do
    date = practice_date(sheet_name)

    %Skillchecker.Stats.FlownShip{
      name: normalize_player_names(Enum.at(row, 1)),
      ship_name:
        normalize_ship_names(
          row
          |> Enum.at(0)
          |> String.replace([" A", " B", " (flag)", " Y", " y"], "")
          |> String.trim()
        ),
      practice_date: date,
      sheet_name: sheet_name
    }
  end

  defp normalize_player_names("Meeto"), do: "meeto"
  defp normalize_player_names(name), do: name

  defp normalize_ship_names("Fleet Cane"), do: "Hurricane Fleet"
  defp normalize_ship_names("Myrm Navy"), do: "Myrmidon Navy Issue"
  defp normalize_ship_names("myrm navy"), do: "Myrmidon Navy Issue"
  defp normalize_ship_names("Harb Navy"), do: "Harbinger Navy Issue"
  defp normalize_ship_names("Harbringer Navy"), do: "Harbinger Navy Issue"
  defp normalize_ship_names("Harbinger Navy"), do: "Harbinger Navy Issue"
  defp normalize_ship_names("Proph Navy"), do: "Prophecy Navy Issue"
  defp normalize_ship_names("Prohp Navy"), do: "Prophecy Navy Issue"
  defp normalize_ship_names("Prophecy Navy"), do: "Prophecy Navy Issue"
  defp normalize_ship_names("Brutix Navy"), do: "Brutix Navy Issue"
  defp normalize_ship_names("Drake Navy"), do: "Drake Navy Issue"
  defp normalize_ship_names("Omen Navy"), do: "Omen Navy Issue"
  defp normalize_ship_names("Bhaal"), do: "Bhaalgorn"
  defp normalize_ship_names("Drek"), do: "Drekavac"
  defp normalize_ship_names("Vigiliant"), do: "Vigilant"
  defp normalize_ship_names("Sentinal"), do: "Sentinel"
  defp normalize_ship_names("Scimi"), do: "Scimitar"
  defp normalize_ship_names("Negal"), do: "Nergal"
  defp normalize_ship_names("Inqisitor"), do: "Inquisitor"
  defp normalize_ship_names("Navy Geddon"), do: "Armageddon Navy Issue"
  defp normalize_ship_names("Armageddon Navy"), do: "Armageddon Navy Issue"
  defp normalize_ship_names("Geddon"), do: "Armageddon"
  defp normalize_ship_names("Exeqoror"), do: "Exequror"
  defp normalize_ship_names("Exeuror"), do: "Exequror"
  defp normalize_ship_names("Augoror"), do: "Auguror"
  defp normalize_ship_names("Exeq Navy"), do: "Exequror Navy"
  defp normalize_ship_names(name), do: name
end
