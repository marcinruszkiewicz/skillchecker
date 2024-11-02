defmodule Skillchecker.GroupFactory do
  @moduledoc false

  alias Skillchecker.Static.Group

  defmacro __using__(_opts) do
    quote do
      def group_factory do
        %Group{
          groupid: 42,
          name: "some name"
        }
      end
    end
  end
end
