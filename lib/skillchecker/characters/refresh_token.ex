defmodule Skillchecker.Characters.RefreshToken do
  @moduledoc """
  Handling of automatic refresh token from EVE API.
  """
  alias Skillchecker.Characters.Character
  alias Skillchecker.Repo

  def auth_header do
    config = Application.fetch_env!(:ueberauth, Ueberauth.Strategy.EVESSO.OAuth)

    "Basic " <> Base.encode64(config[:client_id] <> ":" <> config[:client_secret])
  end

  def refresh_token(character) do
    character.refresh_token
    |> get_token()
    |> parse_response()
    |> update_token(character)
  end

  def get_token(refresh_token) do
    data = %{grant_type: "refresh_token", refresh_token: refresh_token}
    postdata = URI.encode_query(data)

    headers = [
      Accept: "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      Host: "login.eveonline.com",
      Authorization: auth_header()
    ]

    url = "https://login.eveonline.com/v2/oauth/token"

    response = HTTPoison.post(url, postdata, headers)
    response
  end

  def parse_response({:error, _reason}), do: %{}
  def parse_response({:ok, %HTTPoison.Response{status_code: 400}}), do: %{}

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    %{
      "access_token" => token,
      "expires_in" => expiry_seconds
    } = Poison.decode!(body)

    expires_at = DateTime.add(DateTime.utc_now(), expiry_seconds, :second)

    %{token: token, expires_at: expires_at}
  end

  def update_token(attrs, character) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end
end
