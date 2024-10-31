defmodule SkillcheckerWeb.SkillsetLive.Show do
  @moduledoc false
  use SkillcheckerWeb, :live_view

  import SkillcheckerWeb.SkillHelpers

  alias Skillchecker.Skillsets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:skillset, Skillsets.get_skillset!(id))}
  end

  defp page_title(:show), do: "Show Skillset"
  defp page_title(:edit), do: "Edit Skillset"
end
