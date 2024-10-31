defmodule SkillcheckerWeb.DashboardLive.Dashboard do
  @moduledoc false
  use SkillcheckerWeb, :live_view

  import SkillcheckerWeb.SkillHelpers

  alias Skillchecker.Accounts
  alias Skillchecker.Characters

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:characters, Characters.list_pending_characters())
      |> stream(:admins, Accounts.list_pending_admins())

    {:ok, socket}
  end

  @impl true
  def handle_info({SkillcheckerWeb.DashboardLive.CharacterFormComponent, {:saved, character}}, socket) do
    {:noreply, stream_insert(socket, :characters, character)}
  end

  @impl true
  def handle_info({SkillcheckerWeb.DashboardLive.AdminFormComponent, {:saved, admin}}, socket) do
    {:noreply, stream_insert(socket, :admins, admin)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_character, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Character")
    |> assign(:character, Characters.get_character!(id))
  end

  defp apply_action(socket, :edit_admin, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Accounts.get_admin!(id))
  end

  defp apply_action(socket, :dashboard, _params) do
    assign(socket, :page_title, "Dashboard")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    character = Characters.get_character!(id)
    {:ok, _} = Characters.delete_character(character)

    {:noreply, stream_delete(socket, :characters, character)}
  end
end
