defmodule SkillcheckerWeb.AdminUnloggedLive.Login do
  use SkillcheckerWeb, :live_view

  def mount(_params, _session, socket) do
    name = Phoenix.Flash.get(socket.assigns.flash, :name)
    form = to_form(%{"name" => name}, as: "admin")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
