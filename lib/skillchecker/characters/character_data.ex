defmodule Skillchecker.Characters.CharacterData do
  alias Skillchecker.Repo
  alias Skillchecker.Characters.Character

  def update_from_esi(character, token) do
    %{}
    |> get_portraits(character)
    |> get_public_data(character)
    |> get_skillpoints(character, token)
    |> save_esi_data(character)
  end

  def save_esi_data(attrs, character) do
    changes = %{picture_url: attrs.picture_url, thumbnail_url: attrs.thumbnail_url}
    data = attrs |> Map.delete(:picture_url) |> Map.delete(:thumbnail_url)

    result = character
    |> Character.changeset(changes)
    |> Ecto.Changeset.put_embed(:data, data, [])
    |> Repo.update

    {:ok, character} = result
    character
  end

  def get_portraits(attrs, character) do
    %{"px512x512" => picture_url, "px128x128" => thumbnail_url}
      = ESI.API.Character.portrait(character.eveid)
        |> ESI.request!

    Map.merge attrs, %{
      picture_url: picture_url,
      thumbnail_url: thumbnail_url
    }
  end

  def get_public_data(attrs, character) do
    %{
      "corporation_id" => corporation_id,
      "alliance_id" => alliance_id, # optional
      "description" => description
    } = ESI.API.Character.character(character.eveid)
        |> ESI.request!
        |> Enum.into(%{"alliance_id" => nil}) # fill defaults

    Map.merge attrs, %{
      corporation: get_corporation_name(corporation_id),
      alliance: get_alliance_name(alliance_id),
      alliance_id: alliance_id,
      corporation_id: corporation_id,
      bio: description
    }
  end

  def get_alliance_name(nil), do: ""
  def get_alliance_name(alliance_id) do
    %{"name" => alliance_name, "ticker" => alliance_ticker}
      = ESI.API.Alliance.alliance(alliance_id)
        |> ESI.request!

    "#{alliance_name} [#{alliance_ticker}]"
  end

  def get_corporation_name(corporation_id) do
    %{"name" => corp_name, "ticker" => corp_ticker}
      = ESI.API.Corporation.corporation(corporation_id)
        |> ESI.request!

    "#{corp_name} [#{corp_ticker}]"
  end

  def get_skillpoints(attrs, character, token) do
    %{"total_sp" => total_sp, "unallocated_sp" => unallocated_sp}
      = ESI.API.Character.skills(character.eveid, token: token)
        |> ESI.request!
        |> Enum.into(%{"unallocated_sp" => nil})

    Map.merge attrs, %{
      total_sp: total_sp,
      unallocated_sp: unallocated_sp
    }
  end
end