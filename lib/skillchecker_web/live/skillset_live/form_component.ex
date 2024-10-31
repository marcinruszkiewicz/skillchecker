defmodule SkillcheckerWeb.SkillsetLive.FormComponent do
  @moduledoc false
  use SkillcheckerWeb, :live_component

  alias Skillchecker.Skillsets
  alias Skillchecker.Skillsets.Skillset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage skillset records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skillset-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:skill_list]} type="textarea" label="Skills" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Skillset</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skillset: skillset} = assigns, socket) do
    skills = Skillset.export_skill_list(skillset.skills)

    changeset = Skillsets.change_skillset(skillset, %{skill_list: skills})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event("validate", %{"skillset" => skillset_params}, socket) do
    changeset = Skillsets.change_skillset(socket.assigns.skillset, skillset_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"skillset" => skillset_params}, socket) do
    save_skillset(socket, socket.assigns.action, skillset_params)
  end

  defp save_skillset(socket, :edit, skillset_params) do
    case Skillsets.update_skillset(socket.assigns.skillset, skillset_params) do
      {:ok, skillset} ->
        notify_parent({:saved, skillset})

        {:noreply,
         socket
         |> put_flash(:info, "Skillset updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_skillset(socket, :new, skillset_params) do
    case Skillsets.create_skillset(skillset_params) do
      {:ok, skillset} ->
        notify_parent({:saved, skillset})

        {:noreply,
         socket
         |> put_flash(:info, "Skillset created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
