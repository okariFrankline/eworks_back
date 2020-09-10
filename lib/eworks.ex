defmodule Eworks do
  @moduledoc """
  Eworks keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Eworks.Accounts
  alias Eworks.Repo

  @doc """
    Creates a user account and also the profile for the account
  """
  def register_user(params) do
    # create the user
    with {:ok, user} <- Accounts.create_user(params) do
      # create a profile account for the user only after the user has being successfully created.
      _profile = user |> Ecto.build_assoc(:profile, %{emails: [user.auth_email]}) |> Repo.insert!()
      # preload the user to return the user with the profile details
      user = Repo.preload(:profile)
      # return the user
      {:ok, user}
    end
  end # end of register user

end
