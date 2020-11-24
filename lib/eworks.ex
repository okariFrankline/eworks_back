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
  alias Eworks.API.Utils
  alias Eworks.Uploaders.ProfilePicture
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
      {:error, :email_exists, %{message: "Failed. The email address #{params["auth_email"]} is already in use. Please check your email address and try again."}}
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
  def verify_account(%User{} = user, activation_key) do
    # check if the verification key entered by the user and the one stored in the system are equal
    if user.activation_key !== String.to_integer(activation_key) do
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
    Updates the location of a user profile
  """
  def update_user_profile_location(%User{} = user, location_params) do
    # update the profile and return the profile
    with {:ok, user} = result <- Accounts.update_user_location(user, location_params) do
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
  end # end of update_profile_location/2

  @doc """
    Function for updating the user profile
  """
  def update_user_profile_picture(%User{} = user, %Plug.Upload{} = profile_pic) do
    # generste a new name for the file
    profile_pic = Utils.new_upload_name(profile_pic)
    IO.inspect(profile_pic)
    # update the profile pciture
    Accounts.update_user_profile_pic(user, %{profile_pic: profile_pic})
  end # end of update_user_profile/2


  @doc """
    Updates the skills of a given user
  """
  def update_work_profile_skills(%User{} = user, %WorkProfile{} = work_profile, new_skills) do
    # ensure the user is the owner of the work profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Accounts.update_work_profile_skills(work_profile, %{skills: new_skills}) do
        # return the result
        result
        # there are no changese
      else
        :no_change ->
          # return the profile as is
          {:ok, work_profile}
      end # end of with

    else
      # user is not the owner of the profile
      {:error, :not_owner}
    end # end of checking if the owner of the profile
  end # end of the update_profile_skills


  @doc """
    Updates a user's professional introduction
  """
  def update_work_profile_prof_intro(%User{} = _user, %WorkProfile{} = work_profile, prof_intro) do
    # update the profile
    with {:ok, _profile} = result <- Accounts.update_work_profile_prof_intro(work_profile, %{professional_intro: prof_intro}), do: result
  end # end of the update_work_profile_prof_intro/2

  @doc """
    Updates a user's cover letter
  """
  def update_work_profile_cover_letter(%User{} = _user, %WorkProfile{} = work_profile, cover_letter) do
    # update the profile
    with {:ok, _profile} = result <- Accounts.update_work_profile_cover_letter(work_profile, %{cover_letter: cover_letter}), do: result
  end # end of the update_work_profile_prof_intro/2

  @doc """
    false
  """
  def upgrade_client_to_practise(%User{} = user, duration) do
    # preload the work profile for the given user
    user = Repo.preload(user, [:work_profile])
    # check if the user had previously upgraded their work profile
    if user.work_profile and user.work_profile.is_upgraded do
      # update hte last updated and the expiry date of this new upgrade
      with {:ok, _work_profile} = result <- Accounts.update_upgrade_information(user.work_profile, %{upgrade_duration: duration}), do: result
    else
      # the account has not being upgraded
      # create a new upgraded work profile
      with {:ok, _work_profile} = result <- Ecto.build_assoc(user, :work_profile) |> Accounts.create_upgraded_work_profile(%{upgrade_duration: duration}), do: result
    end # end of if for checking if the user had previouslu upgraded their account
  end # end of upgrade_client_to_practise

  @doc """
    Changes the password of the user
  """
  def change_password(%User{} = user, password_params) do
    with {:ok, _user} = result <- Accounts.change_user_password(user, password_params), do: result
  end # end of change_password

   @doc """
    Resends a new activation key
  """
  def resend_activation_key(%User{} = user) do
    # generate key
    key = Enum.random(100000..999999)
    # update the activation key
    user = user |> Ecto.Changeset.change(%{activation_key: key}) |> Repo.update!()
    # send an email notification with the new key
    NewEmail.new_activation_key_email(user, "Eworks Activation Key Resend", "Thank you for registering with Eworks. Here is your new activation key: \n #{key}")
    # send the email
    |> Mailer.deliver_later()

    # return a response
    {:ok, user}
  end # end of resending activation key

  @doc """
    One time upgrade
  """
  def one_time_upgrade(%User{} = user, duration, phone) do
    :ok
  end

end # end of the Eworks module
