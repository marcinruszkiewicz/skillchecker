defmodule SkillcheckerWeb.AdminUnloggedLive.Register do
  @moduledoc false
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Accounts
  alias Skillchecker.Accounts.Admin

  def mount(_params, _session, socket) do
    changeset = Accounts.change_admin_registration(%Admin{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"admin" => admin_params}, socket) do
    case Accounts.register_admin(admin_params) do
      {:ok, admin} ->
        changeset = Accounts.change_admin_registration(admin)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset = Accounts.change_admin_registration(%Admin{}, admin_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "admin")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
