defmodule SkillcheckerWeb.AdminLive.Index do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Admins
  alias Skillchecker.Admins.Admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :admins, Admins.list_admins())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Admins.get_admin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Admin")
    |> assign(:admin, %Admin{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Admins")
    |> assign(:admin, nil)
  end

  @impl true
  def handle_info({SkillcheckerWeb.AdminLive.FormComponent, {:saved, admin}}, socket) do
    {:noreply, stream_insert(socket, :admins, admin)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin = Admins.get_admin!(id)
    {:ok, _} = Admins.delete_admin(admin)

    {:noreply, stream_delete(socket, :admins, admin)}
  end
end
