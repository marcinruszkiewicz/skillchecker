defmodule SkillcheckerWeb.PageController do
  use SkillcheckerWeb, :controller

  def user_landing(conn, _params) do
    render conn, :user_landing, layout: false
  end

  def admin_landing(conn, _params) do
    render conn, :admin_landing, layout: false
  end

  def admin_dashboard(conn, _params) do
    render conn, :admin_dashboard, layout: false
  end
end
