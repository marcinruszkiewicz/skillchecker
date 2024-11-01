defmodule Skillchecker.AccountsTest do
  use Skillchecker.DataCase

  import Assertions
  import Skillchecker.Factory

  alias Skillchecker.Accounts
  alias Skillchecker.Accounts.Admin
  alias Skillchecker.Accounts.AdminToken

  defp setup_admin(_) do
    admin = insert(:admin, name: "Cool Admin")
    token = Accounts.generate_admin_session_token(admin)

    %{admin: admin, token: token}
  end

  describe "get_admin_by_name/1" do
    setup [:setup_admin]

    test "does not return the admin if the name does not exist" do
      refute Accounts.get_admin_by_name("AwfulPlayer")
    end

    test "returns the admin if the name exists", %{admin: admin} do
      assert_structs_equal(admin, Accounts.get_admin_by_name(admin.name), [:id, :name])
    end
  end

  describe "get_admin_by_name_and_password/2" do
    setup [:setup_admin]

    test "does not return the admin if the name does not exist" do
      refute Accounts.get_admin_by_name_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the admin if the password is not valid", %{admin: admin} do
      refute Accounts.get_admin_by_name_and_password(admin.name, "invalid")
    end

    test "returns the admin if the name and password are valid", %{admin: admin} do
      assert_structs_equal(admin, Accounts.get_admin_by_name_and_password(admin.name, "greatest password!"), [:id, :name])
    end
  end

  describe "get_admin!/1" do
    setup [:setup_admin]

    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_admin!(-1)
      end
    end

    test "returns the admin with the given id", %{admin: admin} do
      assert_structs_equal(admin, Accounts.get_admin!(admin.id), [:id, :name])
    end
  end

  describe "register_admin/1" do
    test "requires name and password to be set" do
      {:error, changeset} = Accounts.register_admin(%{})

      assert %{
               password: ["can't be blank"],
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates name and password when given" do
      {:error, changeset} = Accounts.register_admin(%{name: "no", password: "not"})

      assert %{
               password: ["should be at least 6 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for name and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_admin(%{name: too_long, password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "registers admins with a hashed password" do
      name = Faker.Person.name()
      {:ok, admin} = Accounts.register_admin(%{name: name, password: "hello world!"})

      assert admin.name == name
      assert is_binary(admin.hashed_password)
      assert is_nil(admin.password)
    end
  end

  describe "change_admin_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_admin_registration(%Admin{})
      assert changeset.required == [:password, :name]
    end

    test "allows fields to be set" do
      name = Faker.Person.name()
      password = "greatest password!"

      changeset =
        Accounts.change_admin_registration(
          %Admin{},
          %{name: name, password: password}
        )

      assert changeset.valid?
      assert get_change(changeset, :name) == name
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_admin_password/2" do
    test "returns a admin changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_admin_password(%Admin{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_admin_password(%Admin{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_admin_password/3" do
    setup [:setup_admin]

    test "validates password", %{admin: admin} do
      {:error, changeset} =
        Accounts.update_admin_password(admin, "greatest password!", %{
          password: "not",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 6 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{admin: admin} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_admin_password(admin, "greatest password!", %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{admin: admin} do
      {:error, changeset} =
        Accounts.update_admin_password(admin, "invalid", %{password: "greatest password!"})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{admin: admin} do
      {:ok, admin} =
        Accounts.update_admin_password(admin, "greatest password!", %{
          password: "new valid password"
        })

      assert is_nil(admin.password)
      assert Accounts.get_admin_by_name_and_password(admin.name, "new valid password")
    end

    test "deletes all tokens for the given admin", %{admin: admin} do
      _ = Accounts.generate_admin_session_token(admin)

      {:ok, _} =
        Accounts.update_admin_password(admin, "greatest password!", %{
          password: "new valid password"
        })

      refute Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "generate_admin_session_token/1" do
    setup [:setup_admin]

    test "generates a token", %{admin: admin} do
      token = Accounts.generate_admin_session_token(admin)
      assert admin_token = Repo.get_by(AdminToken, token: token)
      assert admin_token.context == "session"

      # Creating the same token for another admin should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%AdminToken{
          token: admin_token.token,
          admin_id: admin.id,
          context: "session"
        })
      end
    end
  end

  describe "get_admin_by_session_token/1" do
    setup [:setup_admin]

    test "returns admin by token", %{admin: admin, token: token} do
      assert session_admin = Accounts.get_admin_by_session_token(token)
      assert session_admin.id == admin.id
    end

    test "does not return admin for invalid token" do
      refute Accounts.get_admin_by_session_token("oops")
    end

    test "does not return admin for expired token", %{token: token} do
      {1, nil} = Repo.update_all(AdminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      refute Accounts.get_admin_by_session_token(token)
    end
  end

  describe "delete_admin_session_token/1" do
    setup [:setup_admin]

    test "deletes the token", %{admin: admin} do
      token = Accounts.generate_admin_session_token(admin)

      assert Accounts.delete_admin_session_token(token) == :ok
      refute Accounts.get_admin_by_session_token(token)
    end
  end

  describe "inspect/2 for the Admin module" do
    test "does not include password" do
      refute inspect(%Admin{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "admins" do
    setup [:setup_admin]

    test "list_admins/0 returns all admins", %{admin: admin} do
      assert_struct_in_list(admin, Accounts.list_admins(), [:id, :name])
    end

    test "change_admin/1 returns a admin changeset", %{admin: admin} do
      assert %Ecto.Changeset{} = Accounts.change_admin(admin)
    end

    test "update_admin/2 with valid data updates the admin", %{admin: admin} do
      update_attrs = %{accepted: true}

      assert {:ok, %Admin{} = admin} = Accounts.update_admin(admin, update_attrs)
      assert admin.accepted == true
    end

    test "update_admin/2 with invalid data returns error changeset", %{admin: admin} do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_admin(admin, %{accepted: nil})

      assert_structs_equal(admin, Accounts.get_admin!(admin.id), [:id, :name])
    end
  end
end
