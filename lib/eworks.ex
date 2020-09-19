defmodule Eworks do
  @moduledoc """
  Eworks keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Eworks.{Accounts}
  alias Eworks.Utils.{Mailer, NewEmail}
  alias Eworks.Repo
  alias Eworks.Accounts.{User, WorkProfile}
  import Ecto.Query, warn: false

  # function for checking whether a user with
  # a given auth_email exist
  defp user_exists?(auth_email) do
    from(
      user in User,
      where: user.auth_email == ^auth_email
    )
    # check if the user exists
    |> Repo.exists?()
  end # end of checking the email address

  @doc """
    Creates a user account and also the profile for the account
  """
  def register_user(:client, params) do
    # check if the user exists
    if not user_exists?(params["auth_email"]) do
      # create the user
      with {:ok, _user} = result <- Accounts.create_user(params), do: result

    else
      # the user does exist
      {:error, :email_exists, %{message: "Failed. The email address #{params["auth_email"]} is already in use."}}
    end # end of checking if the email exists
  end # end of register user

  # register_user for a freelancer
  def register_user(:practise, params) do
    # ensure there is not user with the given email address
    if not user_exists?(params["auth_email"]) do
      # create a new user
      with {:ok, user} <- Accounts.create_user(params) do
        # start a ask for creating a new work profile
        Task.start(fn ->
          # create a new work profile for the given user
          Ecto.build_assoc(user, :work_profile)
          # insert the work profile
          |> Repo.insert!()
        end)
        # return the result
        {:ok, user}
      end # end of eith for creating a new user

    else
      # user exists
      {:error, :email_exists, %{message: "Failed. The email address #{params["auth_email"]} is already in use."}}
    end # end of checking if the account exists
  end # end of registering a user for a practise

  @doc """
    Verifies an account and returns the details with the account
  """
  def verify_account(%User{} = user, activation_key) when is_integer(activation_key) do
    # check if the verification key entered by the user and the one stored in the system are equal
    if user.activation_key !== activation_key do
      # return an error
      {:error, :invalid_activation_key}
    else
      # update the activation to true
      with %User{} = user <- user |> Ecto.Changeset.change(%{is_active: true, activation_key: nil}) |> Repo.update!() do
        if user.user_type == "Client" do
          # return the user
          {:ok, user}
        else
          # return the user preloaded with the work profile
          user = Repo.preload(user, [:work_profile])
          # return the user
          {:ok, user}
        end
      end

    end # end of with for updating the account
  end # end of the verify accounts

  @doc """
    Sends a new activation request to the user
  """
  def send_new_activation_key(%User{} = user) do
    # generate a new activation key requst
    with user <- user |> Ecto.Changeset.change(%{activation_key: Enum.random(100_000..999_999)}) |> Repo.update!() do
      # create a new activation code email
      NewEmail.resend_activation_email(user)
      # send the email
      |> Mailer.deliver_later()
      # return :ok
      :ok
    end # end of inserting a new activation code
  end # end of sending a new activation key

  @doc """
    Updates the location of a user profile
  """
  def update_user_profile_location(%User{} = user, location_params) do
    # update the profile and return the profile
    with {:ok, user} = result <- Accounts.update_user_location(user, location_params) do
      if user.user_type == "Client" do
        # return the user
        {:ok, user}
      else
        # return the user preloaded with the work profile
        user = Repo.preload(user, [:work_profile])
        # return the user
        {:ok, user}
      end
    end # end of with
  end # end of update_profile_location/2

  @doc """
    Updates a user's profile email address
  """
  def update_user_profile_emails(%User{} = user, new_email) do
    # update the phone number
    with {:ok, user} = result <- Accounts.update_user_emails(user, %{email: new_email}) do
      if user.user_type == "Client" do
        # return the user
        result
      else
        # return the user preloaded with the work profile
        user = Repo.preload(user, [:work_profile])
        # return the user
        {:ok, user}
      end
    end # end of with
  end #  end of the update_profile_emails

  @doc """
    Updates a user's profile phone number
  """
  def update_user_profile_phones(%User{} = user, new_phone) do
    # update the phone number
    with {:ok, user} = result <- Accounts.update_user_phones(user, %{phone: new_phone}) do
      if user.user_type == "Client" do
        # return the user
        result
      else
        # return the user preloaded with the work profile
        user = Repo.preload(user, [:work_profile])
        # return the user
        {:ok, user}
      end
    end # end of with
  end #  end of the update_profile_emails


  @doc """
    Updates the skills of a given user
  """
  def update_work_profile_skills(%User{} = user, profile_id, new_skills) do
    # get the work profile
    work_profile = Accounts.get_work_profile!(profile_id)
    # ensure the user is the owner of the work profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Accounts.update_work_profile_skills(work_profile, %{skills: new_skills}) do
        # return the result
        result
        # there are no changese
      else
        :no_changes ->
          # return the profile as is
          {:ok, work_profile}
      end # end of with

    else
      # the user is not the owner
      {:error, :not_owner}
    end # end of the checking if current user is the owner of the profile
  end # end of the update_profile_skills


  @doc """
    Updates a user's professional introduction
  """
  def update_work_profile_prof_intro(%User{} = user, profile_id, prof_intro) do
    # get the work profiel with the given id
    work_profile = Accounts.get_work_profile!(profile_id)
    # ensure the current user is the owner of the profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Accounts.update_work_profile_prof_intro(work_profile, %{professional_intro: prof_intro}), do: result

    else
      # the user is not the owner of the job
      {:error, :not_owner}
    end # end of checking whether the current user is the owner of the profile
  end # end of the update_work_profile_prof_intro/2

  @doc """
    Updates a user's cover letter
  """
  def update_work_profile_cover_letter(%User{} = user, profile_id, cover_letter) do
    # get the work profiel with the given id
    work_profile = Accounts.get_work_profile!(profile_id)
    # ensure the current user is the owner of the profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Accounts.update_work_profile_cover_letter(work_profile, %{cover_letter: cover_letter}), do: result

    else
      # the user is not the owner of the job
      {:error, :not_owner}
    end # end of checking whether the current user is the owner of the profile
  end # end of the update_work_profile_prof_intro/2

end # end of the Eworks module
