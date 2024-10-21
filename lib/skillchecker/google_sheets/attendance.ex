defmodule Skillchecker.GoogleSheets.Attendance do
  def import do
    # setup json key in ~/.config/gcloud/application_default_credentials.json
    practice_tracker_id = "132d74izUpPYoaIDxZPLrX08ARMYT6P8HOcWN0M5K0HA"

    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")
    conn = GoogleApi.Sheets.V4.Connection.new(token.token)

    {:ok, response} = GoogleApi.Sheets.V4.Api.Spreadsheets.sheets_spreadsheets_get(conn, practice_tracker_id)

    response.sheets
    |> get_practice_names()
    |> Enum.each(fn name ->
      get_practice_data(name)
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

  defp practice_attendance_range(sheet_name), do: "'#{sheet_name}'!A2:B"

  defp practice_date(sheet_name) do
    sheet_name
    |> String.split(" - ")
    |> List.first()
    |> Timex.parse!("{D} {Mfull}")
    |> Timex.set(year: 2024)
    |> Timex.to_date()
  end

  def get_practice_data(sheet_name) do
    range = practice_attendance_range(sheet_name)
    date = practice_date(sheet_name)

    practice_tracker_id = "132d74izUpPYoaIDxZPLrX08ARMYT6P8HOcWN0M5K0HA"

    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")
    conn = GoogleApi.Sheets.V4.Connection.new(token.token)

    {:ok, response}
      = GoogleApi.Sheets.V4.Api.Spreadsheets.sheets_spreadsheets_values_get(conn, practice_tracker_id, range)

    response.values
    |> Enum.reject(&Enum.empty?/1)
    |> Enum.reject(fn row -> List.first(row) == "" end)
    |> IO.inspect
    # |> Enum.map(fn row ->
    #   %Skillchecker.Stats.Attendance{
    #     name: List.first(row),
    #     times_flown: List.last(row) |> String.to_integer(),
    #     practice_date: date,
    #     sheet_name: range
    #   }
    # end)
  end
end