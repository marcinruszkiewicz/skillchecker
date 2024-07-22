defmodule SkillcheckerWeb.PageController do
  use SkillcheckerWeb, :controller

  def user_landing(conn, _params) do
    render conn, :user_landing, layout: false
  end

  def admin_landing(conn, _params) do
    render conn, :admin_landing, layout: false
  end

  def admin_waiting(conn, _params) do
    render conn, :admin_waiting, layout: false
  end

  def user_waiting(conn, %{"id" => id} = _params) do
    render conn, :user_waiting, layout: false, id: id
  end
end
