defmodule Eworks.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Eworks.{Repo, Accounts}

  alias Eworks.Profiles.WorkProfile

  # function for creating a new profile user from Accounts user
  def profile_user_from_account_user(%Accounts.User{id: id} = _user), do: %__MODULE__.User{id: id}

  # function for returning an account user from the profile user
  def account_user_from_profile_user(%__MODULE__.User{id: id}  = _user), do: %Accounts.User{id: id}

  @doc """
  Returns the list of work_profiles.

  ## Examples

      iex> list_work_profiles()
      [%WorkProfile{}, ...]

  """
  def list_work_profiles do
    Repo.all(WorkProfile)
  end

  @doc """
  Gets a single work_profile.

  Raises `Ecto.NoResultsError` if the Work profile does not exist.

  ## Examples

      iex> get_work_profile!(123)
      %WorkProfile{}

      iex> get_work_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_profile!(id), do: Repo.get!(WorkProfile, id)

  @doc """
  Creates a work_profile.

  ## Examples

      iex> create_work_profile(%{field: value})
      {:ok, %WorkProfile{}}

      iex> create_work_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_profile(attrs \\ %{}) do
    %WorkProfile{}
    |> WorkProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a work_profile.

  ## Examples

      iex> update_work_profile(work_profile, %{field: new_value})
      {:ok, %WorkProfile{}}

      iex> update_work_profile(work_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_profile(%WorkProfile{} = work_profile, attrs) do
    work_profile
    |> WorkProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a work_profile.

  ## Examples

      iex> delete_work_profile(work_profile)
      {:ok, %WorkProfile{}}

      iex> delete_work_profile(work_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work_profile(%WorkProfile{} = work_profile) do
    Repo.delete(work_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_profile changes.

  ## Examples

      iex> change_work_profile(work_profile)
      %Ecto.Changeset{data: %WorkProfile{}}

  """
  def change_work_profile(%WorkProfile{} = work_profile, attrs \\ %{}) do
    WorkProfile.changeset(work_profile, attrs)
  end

  alias Eworks.Profiles.UserProfile

  @doc """
  Returns the list of user_profiles.

  ## Examples

      iex> list_user_profiles()
      [%UserProfile{}, ...]

  """
  def list_user_profiles do
    Repo.all(UserProfile)
  end

  @doc """
  Gets a single user_profile.

  Raises `Ecto.NoResultsError` if the User profile does not exist.

  ## Examples

      iex> get_user_profile!(123)
      %UserProfile{}

      iex> get_user_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_profile!(id), do: Repo.get!(UserProfile, id)

  @doc """
  Creates a user_profile.

  ## Examples

      iex> create_user_profile(%{field: value})
      {:ok, %UserProfile{}}

      iex> create_user_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_profile(attrs \\ %{}) do
    %UserProfile{}
    |> UserProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_profile.

  ## Examples

      iex> update_user_profile(user_profile, %{field: new_value})
      {:ok, %UserProfile{}}

      iex> update_user_profile(user_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> UserProfile.changeset(attrs)
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
  def update_user_profile_email(%UserProfile{} = profile, attrs) do
    profile
    |> UserProfile.email_changeset(attrs)
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
  def update_user_profile_phone(%UserProfile{} = profile, attrs) do
    profile
    |> UserProfile.phone_changeset(attrs)
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
  def update_user_profile_location(%UserProfile{} = profile, attrs) do
    profile
    |> UserProfile.location_changeset(attrs)
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
  def update_user_profile_bio(%UserProfile{} = profile, attrs) do
    profile
    |> UserProfile.bio_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_profile.

  ## Examples

      iex> delete_user_profile(user_profile)
      {:ok, %UserProfile{}}

      iex> delete_user_profile(user_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_profile(%UserProfile{} = user_profile) do
    Repo.delete(user_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_profile changes.

  ## Examples

      iex> change_user_profile(user_profile)
      %Ecto.Changeset{data: %UserProfile{}}

  """
  def change_user_profile(%UserProfile{} = user_profile, attrs \\ %{}) do
    UserProfile.changeset(user_profile, attrs)
  end
end
