defmodule SkillcheckerWeb.CustomComponents do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: SkillcheckerWeb.Gettext

  attr :refreshed_at, :any

  def last_refreshed(%{refreshed_at: nil} = assigns), do: ~H""

  def last_refreshed(assigns) do
    ~H"""
    <p class="mt-2 text-sm font-medium text-neutral-500 dark:text-slate-300">
      Last refreshed: <%= Timex.format!(@refreshed_at, "{D}/{M}/{YYYY} {h24}:{m}") %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def admin_header(assigns) do
    ~H"""
    <div class="container mx-auto px-4 pt-6 lg:px-8 lg:pt-8 xl:max-w-7xl">
      <div class="flex flex-col gap-2 text-center sm:flex-row sm:items-center sm:justify-between sm:text-start">
        <div class="grow">
          <h1 class="mb-1 text-xl font-bold"><%= render_slot(@inner_block) %></h1>
          <h2 :if={@subtitle != []} class="text-sm font-medium text-neutral-500 dark:text-slate-300">
            <%= render_slot(@subtitle) %>
          </h2>
        </div>
        <div class="flex flex-none items-center justify-center gap-2 rounded sm:justify-end">
          <div class="relative">
            <%= render_slot(@actions) %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
