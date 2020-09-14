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
    field :is_company, :boolean, default: false
    field :is_active, :boolean, default: false
    field :password_hash, :string
    field :user_type, :string
    field :activation_key, :string
    # virtual fields
    field :password, :string, virtual: true
    field :first_name, :string, virtual: true
    field :last_name, :string, virtal: true
    field :company_name, :string, virtual: true
    # has many assigned orders
    has_many :assigned_orders, Eworks.Accounts.AssignedOrder
    # has many sessions ( for authentication )
    has_many :sessions, Eworks.Accounts.Session
    # add the timestamp
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :password_hash,
      :is_active,
      :user_type,
      :activation_key,
      :full_name,
      :is_company
    ])
  end

  @doc false
  def creation_changeset(user, attrs) do
    changeset(user, attrs)
    # cast the password
    |> cast(attrs, [
      :password
      :first_name,
      :last_name,
      :company_name
    ])
    # ensure the email, password and accont type are given
    |> validate_required([
      :auth_email,
      :password,
      :user_type,
    ])
    # add the full name
    |> add_name()
    # ensure the email format is correct
    |> validate_email_format()
    # ensure password is more than 8 characters
    |> validate_length(:password, [
      message: "Failed. Password must be at least 8 characters long"
    ])
    |> hash_password()
    # insert the username from the email address
    |> add_username()
    # generate the activation key
    |> add_activation_key()
    # ensure the email is unique
    |> unique_constraint(:email)
  end # end of the creation changeset

  # function for adding the full name
  defp add_name(%Changeset{changes: %{is_company: is_company}} = changeset) do
    case is_company do
      true ->
        # ensure the fullname is given
        changeset
        |> validate_required([
          :company_name
        ])
        # add the full name
        |> add_full_name()
      false ->
        # ensure the first name and last name is given
        changeset
        |> validate_required([
          :fist_name,
          :last_name
        ])
        # add the full name
        |> add_full_name()
    end # end of the is_company
  end # end of of the add name

  # function for ensuring the first name and last name are given
  defp add_full_name(%Changeset{changes: %{is_company: is_company, first_name: f_name, last_name: l_name, company_name: c_name}} = changeset) do
    # check if the user is a company name
    if is_company do
      # return the changeset
      changeset |> put_change(:full_name, c_name)
    else
      # create the full name
      full_name = "#{String.capitalize(l_name)} #{String.capitalize(f_name)}"
      # return the changeset
      changeset |> put_change(:full_name, full_name)
    end # end of the validate_first_and_last_name
  end # end of the validate_first_and_last_name/1
  defp add_full_name(changeset), do: changeset

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
