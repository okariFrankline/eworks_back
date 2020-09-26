defmodule Eworks.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Eworks.Repo

  alias Eworks.Accounts.{User, Session}

  @doc """
  Creaes a new session for a given user

  ## Examples
      iex> create_session(user, jwt)
        %Session{}

      iex> create_session(user, jwt)
      %Ecto.ChangeError{}
  """
  def store_session(%User{} = user, jwt) do
    # create a new session changeset from te user with the user's id
    user
    |> Ecto.build_assoc(:sessions, %{token: jwt})
    # save to the db
    |> Repo.insert!()
  end # end of the store session function

  @doc """
  Returns true or false is a user with a given email address exists

  ## Examples

      iex> user_with_email_exists?(existing_email)
      true

      iex> user_wih_email_exists?(non_existint_email)
      false
  """
  def user_with_email_exists?(email) when is_binary(email) do
    # query for finding user with given email
    from(
      user in User,
      where: user.auth_email == ^email
    )
    # check if the user exists
    |> Repo.exists?()
  end # end of user_with_email_exists?/1

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
  Gets a single user, specified by an email address

  ## Examples

      iex> get_user_by_email!(existing_email)
      %User{}

      iex> get_user_by_email!(no_existing_email)
      ** nil

  """
  def get_user_by_email(email) when is_binary(email) do
    # query for getting user with the email address
    from(
      user in User,
      where: user.auth_email == ^email
    )
    # return one user
    |> Repo.one()
  end # end of getting user with a given email address

  @doc """
  Gets a single user and does not raise an error.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      {:ok, %User{}}

      iex> get_user!(456)
      ** nil

  """
  def get_user(id), do: Repo.get(User, id)

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
  Updates a profile by adding an email address.

  ## Examples

      iex> add_email_to_profile(profile, %{email: new_value})
      {:ok, %Profile{}}

      iex> add_email_to_profile(profile, %{email: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_emails(%User{} = user, attrs) do
    user
    |> User.email_changeset(attrs)
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
  def update_user_phones(%User{} = user, attrs) do
    user
    |> User.phone_changeset(attrs)
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
  def update_user_location(%User{} = user, attrs) do
    user
    |> User.location_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile picture of the current user.

  ## Examples

      iex> update_user_profile_picprofile, %{city: new_value, country: new_value})
      {:ok, %Profile{}}

      iex> update_user_profile_pic(profile, %{city: bad_value, country: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile_pic(%User{} = user, attrs) do
    user
    |> User.profile_pic_changeset(attrs)
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

  alias Eworks.Accounts.WorkProfile


  @doc """
    Creates a new work profile for a client that is requesting a one time upgrade
  """
  def create_upgraded_work_profile(%WorkProfile{} = profile, attrs \\ %{}) do
    profile
    # pass through the upgrade changeset
    |> WorkProfile.upgrade_changeset(attrs)
    # inserthe profile into the db
    |> Repo.insert()
  end # end of teh create_upgraded_work_prfile/3


  @doc """
    Upgrades the last upgraded and the expiry date of the new upgrade request
  """
  def update_upgrade_information(%WorkProfile{} = profile, attrs \\ %{}) do
    profile
    # pass through the upgrade changeset
    |> WorkProfile.upgrade_changeset(attrs)
    # inserthe profile into the db
    |> Repo.update()
  end # end of the update_upgrade_information

  @doc """
  Gets a single work_profile.

  Raises `Ecto.NoResultsError` if the Work profile does not exist.

  ## Examples

      iex> get_work_profile!(123)
      %WorkProfile{}

      iex> get_work_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_profile!(id), do: Repo.get!(WorkProfile, id) |> Repo.preload(:user)

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
  Updates a work profile's skills.

  ## Examples

      iex> update_work_profile_skills(profile, %{bio: new_value})
      {:ok, %Profile{}}

      iex> update_work_profile_skills(profile, %{bio: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_profile_skills(%WorkProfile{} = profile, attrs) do
    changeset = profile |> WorkProfile.skills_changeset(attrs)
    # check the action of the changeset
    if changeset.action != nil do
      # update the profile
      changeset |> Repo.update()
    else
      # return no change
      :no_change
    end # end of checking the changeset
  end # end of the update_work_profile_skills/2

  @doc """
  Updates a work profile's professional intro.

  ## Examples

      iex> update_work_prof_intro(profile, %{email: new_value})
      {:ok, %Profile{}}

      iex> update_work_prof_intro(profile, %{email: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_profile_prof_intro(%WorkProfile{} = profile, attrs) do
    profile
    |> WorkProfile.professional_intro_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a work profile's cover letter.

  ## Examples

      iex> update_work_cover_letter(profile, %{email: new_value})
      {:ok, %Profile{}}

      iex> update_work_cover_letter(profile, %{email: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_profile_cover_letter(%WorkProfile{} = profile, attrs) do
    profile
    |> WorkProfile.cover_letter_changeset(attrs)
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
end # end of the module
