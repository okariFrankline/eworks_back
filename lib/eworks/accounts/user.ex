defmodule Eworks.Accounts.User do
  use Ecto.Schema
  # use the arc ecto
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  alias Eworks.Utils.Validations
  alias Eworks.Accounts.Utils

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :full_name, :string
    field :auth_email, :string
    field :is_company, :boolean
    field :is_active, :boolean, default: false
    field :is_suspended, :boolean, default: false
    field :profile_complete, :boolean, default: false
    field :password_hash, :string
    field :user_type, :string
    field :activation_key, :integer
    field :username, :string
    # indicates whether the user has a work profile due to an upgrade
    field :is_upgraded_contractor, :boolean, default: false
    # indicates whether an upgrade contractor has a complete work profile
    field :has_complete_work_profile, :boolean, default: false
    # profile information
    field :city, :string
    field :country, :string
    # phone
    field :phone, :string
    #field :phones, {:array, :string}
    field :saved_workers, {:array, :binary_id}
    field :profile_pic, Eworks.Uploaders.ProfilePicture.Type
    # virtual fields
    field :current_password, :string, virtual: true
    field :password, :string, virtual: true
    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true
    field :company_name, :string, virtual: true
    # tokens
    field :token, :integer
    # has many sessions ( for authentication )
    has_many :sessions, Eworks.Accounts.Session
    # has many order offers
    has_many :order_offers, Eworks.Orders.OrderOffer
    # has many order offers
    has_many :invite_offers, Eworks.Collaborations.InviteOffer
    # has one work profile
    has_one :work_profile, Eworks.Accounts.WorkProfile
    # has many notifications
    has_many :notifications, Eworks.Notifications.Notification
    # has many direct hire requests created
    has_many :direct_hires, Eworks.Requests.DirectHire
    # has many orders
    has_many :orders, Eworks.Orders.Order
    # add the timestamp
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :auth_email,
      :password_hash,
      :is_active,
      :user_type,
      :activation_key,
      :full_name,
      :is_company,
      :username,
      :country,
      :city,
      :is_suspended,
      :saved_workers,
      :profile_complete,
      :is_upgraded_contractor,
      :phone,
      :has_complete_work_profile,
      :token
    ])
    # cast the profile_pic attachmetns
    |> cast_attachments(attrs, [
      :profile_pic
    ])
  end


  def profile_pic_changeset(user, attrs) do
    changeset(user, attrs)
    # cast the profile_pic
    |> cast_attachments(attrs, [
      :profile_pic
    ])
    # ensure the profile_picture is given
    |> validate_required([
      :profile_pic
    ])
  end

  @doc false
  def password_changeset(user, attrs) do
    changeset(user, attrs)
    # cast the password and current password
    |> cast(attrs, [
      :password,
      :current_password
    ])
    # ensure they are given
    |> validate_required([
      :password,
      :current_password
    ])
    # update hte passwrd
    |> update_password()
  end # end of password_changeset

  @doc false
  def creation_changeset(user, attrs) do
    changeset(user, attrs)
    # cast the password
    |> cast(attrs, [
      :password
    ])
    # ensure the email, password and accont type are given
    |> validate_required([
      :auth_email,
      :password,
      :user_type,
      :is_company,
      :full_name
    ])
    # ensure the email format is correct
    |> validate_auth_email_format()
    # ensure password is more than 8 characters
    |> validate_length(:password, [
      min: 8,
      message: "Failed. Password must be at least 8 characters long"
    ])
    |> hash_password()
    # insert the username from the email address
    |> add_username()
    # generate the activation key
    |> add_activation_key()
    # ensure the email is unique
    |> unique_constraint(:auth_email)
  end # end of the creation changeset

  @doc false
  def phone_changeset(profile, attrs) do
    changeset(profile, attrs)
    # cast the phone
    |> cast(attrs, [
      :phone
    ])
    # ensure the phone numer is given
    |> validate_required([
      :phone
    ], message: "Failed. Phone number is required.")
    # validate the phone number
    |> validate_phone()
    # ensure the phone is unique
    |> unique_constraint(:phone)
  end # end of the phone changeset

  @doc false
  def auth_email_changeset(user, attrs) do
    changeset(user, attrs)
    # ensure the auth email is given
    |> validate_required([
      :auth_email
    ])
    # validate the email address
    |> validate_auth_email_format()
    # add the new username
    |> add_username()
  end # end of adding the auth email


  @doc false
  def location_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure country and city are given
    |> validate_required([
      :country,
      :city
    ])
  end # end of the location changeset

  # functon for validaing the email address
  defp validate_auth_email_format(%Changeset{valid?: true, changes: %{auth_email: email }} = changeset) do
    # validate the email
    if Validations.is_valid_email?(email) do
      # return the changeset as is
      changeset
    else
      # add an error in the changeset
      changeset |> add_error(:auth_email, "Failed. The email address: #{email} has an invalid format")
    end # end of if
  end # end of function for validating the email format
  defp validate_auth_email_format(changeset), do: changeset

  # function for adding the username
  defp add_username(%Changeset{valid?: true, changes: %{auth_email: email}} = changeset) do
    [_email, username, _domain] = Utils.get_username(email)
    # add the username to the changeset
    changeset |> put_change(:username, username)
  end # end of changeset
  defp add_username(changeset), do: changeset

  # function for hashing the passwprd
  defp hash_password(%Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    changeset
    # hash the password and add it to the changeset
    |> put_change(:password_hash, Argon2.hash_pwd_salt(pass))
  end # end of hash_password/1
  defp hash_password(changeset), do: changeset

  # function for adding the activation key
  defp add_activation_key(%Changeset{valid?: true} = changeset) do
    changeset
    # generate a random number between 100000 to 999999
    |> put_change(:activation_key, Enum.random(100_000..999_999))
  end # end of the activation key
  defp add_activation_key(changeset), do: changeset

  # function for validating phone numbers and adding to the list of phone numbers
  def validate_phone(%Changeset{valid?: true, changes: %{phone: phone}, data: %__MODULE__{country: country}} = changeset) do
    case Validations.is_valid_phone?(phone, country) do
      # the phone number is valid
      {:ok, phone_number} ->
        # add the phone number to the list of phone numbers and update the changeset
        changeset |> put_change(:phone, phone_number)

      # the phone number is invalid
      :error ->
        changeset
        # add error message to changeset phone
        |> add_error(:phone, "Failed. The phone number #{phone} has an invalid format or is invalid for your country, #{country}.")
    end # end of if
  end # end ov validate_phone_and_add_to_phones/1
  def validate_phone(changeset), do: changeset

  # function that updates the password
  defp update_password(%Changeset{valid?: true, changes: %{password: new_pass, current_password: current_pass}, data: %__MODULE__{password_hash: hash}} = changeset) do
    if Utils.validate_current_password(hash, current_pass) do
      # check if new password and current passwords are similer
      if new_pass == current_pass do
        # put the change
        changeset
        |> put_change(:password_hash, Argon2.hash_pwd_salt(new_pass))
        # set the current pass to nil
        |> put_change(:current_password, nil)
        # set the password to nil
        |> put_change(:password, nil)
      else
        # return the changeset
        changeset
      end # end of checking if new and current passwords are similar
    else
      # ass error
      changeset |> add_error(:current_password, "Failed. Current password entered is wrong.")
    end # end of if
  end # end of update_password/1
  defp update_password(changeset), do: changeset

end # end of the Eworks.Accounts.User module
