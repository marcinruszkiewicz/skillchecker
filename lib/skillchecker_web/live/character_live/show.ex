defmodule SkillcheckerWeb.CharacterLive.Show do
  @moduledoc false
  use SkillcheckerWeb, :live_view

  import SkillcheckerWeb.SkillHelpers

  alias Skillchecker.Characters
  alias Skillchecker.Skillsets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:character, Characters.get_character!(id))
      |> assign(:skillsets, Skillsets.list_skillsets())
    }
  end

  defp page_title(:show), do: "Show Character"
  defp page_title(:edit), do: "Edit Character"
end
