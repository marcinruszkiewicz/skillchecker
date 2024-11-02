defmodule Skillchecker.Characters.Character do
  @moduledoc """
  Character imported from EVE API
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Skillchecker.Skillsets.Skillset

  schema "characters" do
    field :accepted, :boolean
    field :eveid, :integer
    field :owner_hash, :string
    field :name, :string
    field :picture_url, :string
    field :thumbnail_url, :string

    field :token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    belongs_to :primary, Skillset
    belongs_to :secondary, Skillset
    belongs_to :tertiary, Skillset

    embeds_one :data, Data, on_replace: :update do
      field :bio, :string
      field :corporation, :string
      field :alliance, :string
      field :alliance_id, :integer
      field :corporation_id, :integer

      # skills endpoint
      field :total_sp, :integer
      field :unallocated_sp, :integer
    end

    embeds_many :skill_queue, QueuedSkill, on_replace: :delete do
      field :name, :string
      field :skill_id, :integer
      field :queue_position, :integer
      field :finished_level, :integer
      field :finish_date, :utc_datetime
      field :start_date, :utc_datetime
      field :training_start_sp, :integer
      field :level_start_sp, :integer
      field :level_end_sp, :integer
    end

    embeds_many :skills, Skill, on_replace: :delete do
      field :skill_id, :integer
      field :active_level, :integer
      field :trained_level, :integer
      field :skill_points, :integer
      field :name, :string
      field :group, :string
    end

    timestamps()
  end

  @doc false
  def changeset(character, attrs \\ %{}) do
    character
    |> cast(attrs, [
      :accepted,
      :name,
      :thumbnail_url,
      :picture_url,
      :owner_hash,
      :eveid,
      :expires_at,
      :token,
      :refresh_token,
      :primary_id,
      :secondary_id,
      :tertiary_id
    ])
    |> cast_embed(:data)
    |> cast_embed(:skills)
    |> cast_embed(:skill_queue)
    |> validate_required([:name, :owner_hash, :eveid])
  end

  def token_expired?(character) do
    DateTime.diff(character.expires_at, DateTime.utc_now()) <= 0
  end
end
