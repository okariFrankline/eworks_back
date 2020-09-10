defmodule Eworks.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Eworks.Repo

  alias Eworks.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Eworks.Accounts.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)


  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile by adding an email address.

  ## Examples

      iex> add_email_to_profile(profile, %{email: new_value})
      {:ok, %Profile{}}

      iex> add_email_to_profile(profile, %{email: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile_email(%Profile{} = profile, attrs) do
    profile
    |> Profile.email_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile by adding a phone number.

  ## Examples

      iex> add_phone_to_profile(profile, %{phone: new_value})
      {:ok, %Profile{}}

      iex> add_phone_to_profile(profile, %{phone: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile_phone(%Profile{} = profile, attrs) do
    profile
    |> Profile.phone_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile by adding city and country to the profile.

  ## Examples

      iex> add_location_to_profile(profile, %{city: new_value, country: new_value})
      {:ok, %Profile{}}

      iex> add_location_to_profile(profile, %{city: bad_value, country: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile_location(%Profile{} = profile, attrs) do
    profile
    |> Profile.location_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile by adding about details to the profile.

  ## Examples

      iex> add_about_to_profile(profile, %{about: new_value})
      {:ok, %Profile{}}

      iex> add_about_to_profile(profile, %{about: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile_about(%Profile{} = profile, attrs) do
    profile
    |> Profile.about_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile by adding bio details to the user.

  ## Examples

      iex> add_bio_to_profile(profile, %{bio: new_value})
      {:ok, %Profile{}}

      iex> add_bio_to_profile(profile, %{bio: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile_bio(%Profile{} = profile, attrs) do
    profile
    |> Profile.bio_changeset(attrs)
    |> Repo.update()
  end

end # end of the module
