defmodule Skillchecker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Skillchecker.Accounts.Admin
  alias Skillchecker.Accounts.AdminToken
  alias Skillchecker.Repo

  ## Database getters

  @doc """
  Gets a admin by name.

  ## Examples

      iex> get_admin_by_name("someName")
      %Admin{}

      iex> get_admin_by_name("unknown")
      nil

  """
  def get_admin_by_name(name) when is_binary(name) do
    Repo.get_by(Admin, name: name)
  end

  @doc """
  Gets a admin by name and password.

  ## Examples

      iex> get_admin_by_name_and_password("someName", "correct_password")
      %Admin{}

      iex> get_admin_by_name_and_password("someName", "invalid_password")
      nil

  """
  def get_admin_by_name_and_password(name, password) when is_binary(name) and is_binary(password) do
    admin = Repo.get_by(Admin, name: name)
    if Admin.valid_password?(admin, password), do: admin
  end

  @doc """
  Gets a single admin.

  Raises `Ecto.NoResultsError` if the Admin does not exist.

  ## Examples

      iex> get_admin!(123)
      %Admin{}

      iex> get_admin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_admin!(id), do: Repo.get!(Admin, id)

  @doc """
  Returns the list of admins.

  ## Examples

      iex> list_admins()
      [%Admin{}, ...]

  """
  def list_admins do
    Repo.all(Admin)
  end

  @doc """
  Returns the list of admins.

  ## Examples

      iex> list_pending_admins()
      [%Admin{}, ...]

  """
  def list_pending_admins do
    Admin
    |> where(accepted: false)
    |> Repo.all()
  end

  @doc """
  Updates a admin.

  ## Examples

      iex> update_admin(admin, %{field: new_value})
      {:ok, %Admin{}}

      iex> update_admin(admin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking admin changes.

  ## Examples

      iex> change_admin(admin)
      %Ecto.Changeset{data: %Admin{}}

  """
  def change_admin(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end

  ## Admin registration

  @doc """
  Registers a admin.

  ## Examples

      iex> register_admin(%{field: value})
      {:ok, %Admin{}}

      iex> register_admin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_admin(attrs) do
    %Admin{}
    |> Admin.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking admin changes.

  ## Examples

      iex> change_admin_registration(admin)
      %Ecto.Changeset{data: %Admin{}}

  """
  def change_admin_registration(%Admin{} = admin, attrs \\ %{}) do
    Admin.registration_changeset(admin, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the admin password.

  ## Examples

      iex> change_admin_password(admin)
      %Ecto.Changeset{data: %Admin{}}

  """
  def change_admin_password(admin, attrs \\ %{}) do
    Admin.password_changeset(admin, attrs, hash_password: false)
  end

  @doc """
  Updates the admin password.

  ## Examples

      iex> update_admin_password(admin, "valid password", %{password: ...})
      {:ok, %Admin{}}

      iex> update_admin_password(admin, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_admin_password(admin, password, attrs) do
    changeset =
      admin
      |> Admin.password_changeset(attrs)
      |> Admin.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:admin, changeset)
    |> Ecto.Multi.delete_all(:tokens, AdminToken.by_admin_and_contexts_query(admin, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{admin: admin}} -> {:ok, admin}
      {:error, :admin, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_admin_session_token(admin) do
    {token, admin_token} = AdminToken.build_session_token(admin)
    Repo.insert!(admin_token)
    token
  end

  @doc """
  Gets the admin with the given signed token.
  """
  def get_admin_by_session_token(token) do
    {:ok, query} = AdminToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_admin_session_token(token) do
    Repo.delete_all(AdminToken.by_token_and_context_query(token, "session"))
    :ok
  end
end
