defmodule SkillcheckerWeb.RequireAcceptedAdmin do
  @moduledoc """
  Used in the router to make sure admins are accepted before
  using any of the application.
  """
  import Plug.Conn

  alias Phoenix.Controller
  alias Skillchecker.Accounts
  alias Skillchecker.Accounts.Admin

  def init(config), do: config

  def call(conn, _) do
    admin_token = get_session(conn, :admin_token)

    (admin_token && Accounts.get_admin_by_session_token(admin_token))
    |> accepted?()
    |> maybe_halt(conn)
  end

  defp accepted?(%Admin{accepted: true}), do: true
  defp accepted?(_user), do: false

  defp maybe_halt(true, conn), do: conn

  defp maybe_halt(_any, conn) do
    conn
    |> Controller.put_flash(:error, "You need to be accepted to log in.")
    |> Controller.redirect(to: waiting_path(conn))
    |> halt()
  end

  defp waiting_path(_conn), do: "/admin/waiting"
end
