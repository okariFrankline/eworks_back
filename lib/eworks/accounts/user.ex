defmodule Eworks.Accounts.User do
  use Ecto.Schema
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
    field :password_hash, :string
    field :user_type, :string
    field :activation_key, :integer
    field :username, :string
    # profile information
    field :city, :string
    field :country, :string
    field :email, :string, virtual: true
    field :emails, {:array, :string}
    field :phone, :string, virtual: true
    field :phones, {:array, :string}
    field :profile_pic, :string
    # virtual fields
    field :password, :string, virtual: true
    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true
    field :company_name, :string, virtual: true
    # has many assigned orders
    has_many :assigned_orders, Eworks.Accounts.AssignedOrder
    # has many sessions ( for authentication )
    has_many :sessions, Eworks.Accounts.Session
    # has many order offers
    has_many :order_offers, Eworks.Orders.OrderOffer
    # has one work profile
    has_one :work_profile, Eworks.Accounts.WorkProfile
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
      :emails,
      :phones,
      :profile_pic
    ])
  end

  @doc false
  def creation_changeset(user, attrs) do
    changeset(user, attrs)
    # cast the password
    |> cast(attrs, [
      :password,
      :first_name,
      :last_name,
      :company_name
    ])
    # ensure the email, password and accont type are given
    |> validate_required([
      :auth_email,
      :password,
      :user_type,
      :is_company
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
    # add name
    |> add_name()
    # ensure the email is unique
    |> unique_constraint(:auth_email)
  end # end of the creation changeset

  @doc false
  def email_changeset(profile, attrs) do
    changeset(profile, attrs)
    # cast the email
    |> cast(attrs, [
      :email
    ])
    # ensure the email is provided
    |> validate_required([
      :email
    ], message: "Failed. Email address is required.")
    # validate the email address
    |> validate_email_and_add_to_emails()
  end

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
    |> validate_phone_and_add_to_phones()
  end # end of the phone changeset


  @doc false
  def location_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure country and city are given
    |> validate_required([
      :country,
      :city
    ])
  end # end of the location changeset

  # function for adding the full name if the user is a companu
  defp add_name(%Changeset{valid?: true, changes: %{is_company: is_company}} = changeset) when is_company == true do
    changeset
    |> validate_required([
      :company_name
    ])
    |> put_change(:full_name, changeset.changes.company_name)
  end
  # function for adding the full name if the user is not a compnay
  defp add_name(%Changeset{valid?: true, changes: %{is_company: is_company}} = changeset) when is_company == false do
    # create the full name
    full_name = "#{String.capitalize(changeset.changes.first_name)} #{String.capitalize(changeset.changes.last_name)}"
    changeset
    |> validate_required([
      :first_name,
      :last_name
    ])
    |> put_change(:full_name, full_name)
  end
  # called if changeset is invalid
  defp add_name(changeset), do: changeset

  # functon for validaing the email address
  defp validate_auth_email_format(%Changeset{valid?: true, changes: %{auth_email: email }} = changeset) do
    # validate the email
    if Validations.is_valid_email?(email) do
      # return the changeset as is
      changeset |> put_change(:emails, [email])
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
  def validate_phone_and_add_to_phones(%Changeset{valid?: true, changes: %{phone: phone}, data: %__MODULE__{phones: phones, country: country}} = changeset) do
    if Validations.is_valid_phone?(phone, country) do
      # add the phone number to the list of phone numbers and update the changeset
      changeset |> put_change(:phones, [phone | phones]) |> put_change(:phone, nil)
    else
      changeset
      # add error message to changeset phone
      |> add_error(:phone, "Failed. The phone number #{phone} has an invalid format or is invalid for your country.")
      # set the phone to nil
      |> put_change(:phone, nil)
    end # end of if
  end # end ov validate_phone_and_add_to_phones/1
  def validate_phon_and_add_to_phones(changeset), do: changeset

  # function for validating the email format
  defp validate_email_and_add_to_emails(%Changeset{valid?: true, changes: %{email: email}, data: %__MODULE__{emails: emails}} = changeset) do
    # check if the email given is valid
    if Validations.is_valid_email?(email) do
      # add the email to the list of emails and upadate the changeset
      changeset |> put_change(:emails, [email | emails])
    else
      # add an error to the changeset
      changeset |> add_error(:email, "Failed. The email address: #{email} is invalid.")
    end # end of if
  end # end of validate_email_format/1
  defp validate_email_and_add_to_emails(changeset), do: changeset

end # end of the Eworks.Accounts.User module
