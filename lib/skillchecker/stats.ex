defmodule Skillchecker.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false

  alias Skillchecker.Repo
  alias Skillchecker.Stats.Attendance

  def list_attendance_stats do
    query =
      from a in Attendance,
        group_by: a.name,
        select: %{
          id: a.name,
          name: a.name,
          matches: sum(a.times_flown),
          practices: count(a.times_flown),
          last_practice_date: max(a.practice_date),
          last_practice_name:
            fragment(
              "(ARRAY_AGG(? order by make_date(extract(year from current_date)::int, extract(month from to_date(?, 'dd Mon'))::int, extract(day from to_date(?, 'dd Mon'))::int) DESC))[1]",
              a.sheet_name,
              a.sheet_name,
              a.sheet_name
            )
        },
        order_by: [desc: sum(a.times_flown)]

    Repo.all(query)
  end
end
