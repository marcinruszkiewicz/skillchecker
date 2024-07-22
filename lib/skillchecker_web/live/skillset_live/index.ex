defmodule SkillcheckerWeb.SkillsetLive.Index do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Skillsets
  alias Skillchecker.Skillsets.Skillset

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :skillsets, Skillsets.list_skillsets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    skillset = Skillsets.get_skillset!(id)

    socket
    |> assign(:page_title, "Edit Skillset")
    |> assign(:skillset, skillset)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Skillset")
    |> assign(:skillset, %Skillset{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Skillsets")
    |> assign(:skillset, nil)
  end

  @impl true
  def handle_info({SkillcheckerWeb.SkillsetLive.FormComponent, {:saved, skillset}}, socket) do
    {:noreply, stream_insert(socket, :skillsets, skillset)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    skillset = Skillsets.get_skillset!(id)
    {:ok, _} = Skillsets.delete_skillset(skillset)

    {:noreply, stream_delete(socket, :skillsets, skillset)}
  end
end
