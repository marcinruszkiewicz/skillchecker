defmodule SkillcheckerWeb.AdminUnloggedLive.Forgot do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "admin"))}
  end

  def handle_event("send_email", %{"admin" => %{"email" => email}}, socket) do
    if admin = Accounts.get_admin_by_email(email) do
      Accounts.deliver_admin_reset_password_instructions(
        admin,
        &url(~p"/admin/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/admin")}
  end
end
