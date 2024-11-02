defmodule Skillchecker.AdminFactory do
  @moduledoc false

  alias Skillchecker.Accounts.Admin

  defmacro __using__(_opts) do
    quote do
      def admin_factory do
        %Admin{
          hashed_password: Bcrypt.hash_pwd_salt("greatest password!"),
          name: Faker.Person.name(),
          accepted: true
        }
      end
    end
  end
end
