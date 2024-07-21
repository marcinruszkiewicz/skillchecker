defmodule SkillcheckerWeb.AdminLive.Index do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :admins, Accounts.list_admins())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Accounts.get_admin!(id))
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
end
