defmodule Skillchecker.AccountsTest do
  use Skillchecker.DataCase

  import Skillchecker.AccountsFixtures

  alias Skillchecker.Accounts
  alias Skillchecker.Accounts.Admin
  alias Skillchecker.Accounts.AdminToken

  describe "get_admin_by_name/1" do
    test "does not return the admin if the name does not exist" do
      refute Accounts.get_admin_by_name("AwfulPlayer")
    end

    test "returns the admin if the name exists" do
      %{id: id} = admin = admin_fixture()
      assert %Admin{id: ^id} = Accounts.get_admin_by_name(admin.name)
    end
  end

  describe "get_admin_by_name_and_password/2" do
    test "does not return the admin if the name does not exist" do
      refute Accounts.get_admin_by_name_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the admin if the password is not valid" do
      admin = admin_fixture()
      refute Accounts.get_admin_by_name_and_password(admin.name, "invalid")
    end

    test "returns the admin if the name and password are valid" do
      %{id: id} = admin = admin_fixture()

      assert %Admin{id: ^id} = Accounts.get_admin_by_name_and_password(admin.name, valid_admin_password())
    end
  end

  describe "get_admin!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_admin!(-1)
      end
    end

    test "returns the admin with the given id" do
      %{id: id} = admin = admin_fixture()
      assert %Admin{id: ^id} = Accounts.get_admin!(admin.id)
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
      name = unique_admin_name()
      {:ok, admin} = Accounts.register_admin(valid_admin_attributes(name: name))

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
      name = unique_admin_name()
      password = valid_admin_password()

      changeset =
        Accounts.change_admin_registration(
          %Admin{},
          valid_admin_attributes(name: name, password: password)
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
    setup do
      %{admin: admin_fixture()}
    end

    test "validates password", %{admin: admin} do
      {:error, changeset} =
        Accounts.update_admin_password(admin, valid_admin_password(), %{
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
        Accounts.update_admin_password(admin, valid_admin_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{admin: admin} do
      {:error, changeset} =
        Accounts.update_admin_password(admin, "invalid", %{password: valid_admin_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{admin: admin} do
      {:ok, admin} =
        Accounts.update_admin_password(admin, valid_admin_password(), %{
          password: "new valid password"
        })

      assert is_nil(admin.password)
      assert Accounts.get_admin_by_name_and_password(admin.name, "new valid password")
    end

    test "deletes all tokens for the given admin", %{admin: admin} do
      _ = Accounts.generate_admin_session_token(admin)

      {:ok, _} =
        Accounts.update_admin_password(admin, valid_admin_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(AdminToken, admin_id: admin.id)
    end
  end

  describe "generate_admin_session_token/1" do
    setup do
      %{admin: admin_fixture()}
    end

    test "generates a token", %{admin: admin} do
      token = Accounts.generate_admin_session_token(admin)
      assert admin_token = Repo.get_by(AdminToken, token: token)
      assert admin_token.context == "session"

      # Creating the same token for another admin should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%AdminToken{
          token: admin_token.token,
          admin_id: admin_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_admin_by_session_token/1" do
    setup do
      admin = admin_fixture()
      token = Accounts.generate_admin_session_token(admin)

      %{admin: admin, token: token}
    end

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
    test "deletes the token" do
      admin = admin_fixture()
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
    setup do
      %{admin: admin_fixture()}
    end

    @invalid_attrs %{name: nil}

    test "list_admins/0 returns all admins", %{admin: admin} do
      assert_struct_in_list(admin, Accounts.list_admins(), [:id, :name])
    end

    test "change_admin/1 returns a admin changeset" do
      admin = admin_fixture()
      assert %Ecto.Changeset{} = Accounts.change_admin(admin)
    end

    test "update_admin/2 with valid data updates the admin" do
      admin = admin_fixture()
      update_attrs = %{accepted: true}

      assert {:ok, %Admin{} = admin} = Accounts.update_admin(admin, update_attrs)
      assert admin.accepted == true
    end

    test "update_admin/2 with invalid data returns error changeset" do
      admin = admin_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_admin(admin, @invalid_attrs)

      assert_structs_equal(admin, Accounts.get_admin!(admin.id), [:id, :name])
    end
  end
end
