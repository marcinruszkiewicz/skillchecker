defmodule SkillcheckerWeb.AdminLive.Show do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Admins

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:admin, Admins.get_admin!(id))}
  end

  defp page_title(:show), do: "Show Admin"
  defp page_title(:edit), do: "Edit Admin"
end
