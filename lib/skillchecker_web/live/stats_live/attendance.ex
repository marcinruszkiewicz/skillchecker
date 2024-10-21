defmodule SkillcheckerWeb.StatsLive.Attendance do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Stats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :attendance, Stats.list_attendance_stats())}
  end
end
