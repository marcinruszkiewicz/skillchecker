defmodule SkillcheckerWeb.AdminLive.FormComponent do
  use SkillcheckerWeb, :live_component

  alias Skillchecker.Admins

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage admin records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="admin-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:accepted]} type="checkbox" label="Accepted" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Admin</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{admin: admin} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Admins.change_admin(admin))
     end)}
  end

  @impl true
  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset = Admins.change_admin(socket.assigns.admin, admin_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"admin" => admin_params}, socket) do
    save_admin(socket, socket.assigns.action, admin_params)
  end

  defp save_admin(socket, :edit, admin_params) do
    case Admins.update_admin(socket.assigns.admin, admin_params) do
      {:ok, admin} ->
        notify_parent({:saved, admin})

        {:noreply,
         socket
         |> put_flash(:info, "Admin updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_admin(socket, :new, admin_params) do
    case Admins.create_admin(admin_params) do
      {:ok, admin} ->
        notify_parent({:saved, admin})

        {:noreply,
         socket
         |> put_flash(:info, "Admin created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
