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
end # end of the module
