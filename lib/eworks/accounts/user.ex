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
      :username
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
    |> validate_email_format()
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
  defp validate_email_format(%Changeset{valid?: true, changes: %{auth_email: email }} = changeset) do
    # validate the email
    if Validations.is_valid_email?(email) do
      # return the changeset as is
      changeset
    else
      # add an error in the changeset
      changeset |> add_error(:auth_email, "Failed. The email address: #{email} has an invalid format")
    end # end of if
  end # end of function for validating the email format
  defp validate_email_format(changeset), do: changeset

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

end
