defmodule SkillcheckerWeb.AdminSessionController do
  use SkillcheckerWeb, :controller

  alias Skillchecker.Accounts
  alias SkillcheckerWeb.AdminAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:admin_return_to, ~p"/admin/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"admin" => admin_params}, info) do
    %{"name" => name, "password" => password} = admin_params

    if admin = Accounts.get_admin_by_name_and_password(name, password) do
      conn
      |> put_flash(:info, info)
      |> AdminAuth.log_in_admin(admin, admin_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the name is registered.
      conn
      |> put_flash(:error, "Invalid name or password")
      |> put_flash(:name, String.slice(name, 0, 160))
      |> redirect(to: ~p"/admin/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> AdminAuth.log_out_admin()
  end
end
