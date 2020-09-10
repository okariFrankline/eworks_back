defmodule Eworks.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Eworks.Utils.Validations

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field :about, :string
    field :city, :string
    field :company_name, :string
    field :country, :string
    field :email, :string, virtual: true
    field :emails, {:array, :string}
    field :first_name, :string
    field :last_name, :string
    field :phone, :string, virtual: true
    field :phones, {:array, :string}
    field :profile_pic, :string
    belongs_to :user, Eworks.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :first_name,
      :last_name,
      :company_name,
      :country,
      :city,
      :emails,
      :phones,
      :about,
      :profile_pic
    ])
  end

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
  def bio_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure first, last name are required
    |> validate_required([
      :first_name,
      :last_name
    ])
  end # end of bio_changeset/2

  @doc false
  def location_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure country and city are given
    |> validate_required([
      :county,
      :city
    ])
  end # end of the location changeset

  @doc false
  def about_changeset(profile, attrs), do: changeset(profile, attrs) |> validate_required([:about])

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

  # function for validating phone numbers and adding to the list of phone numbers
  def validate_phone_and_add_to_phones(%Changeset{valid?: true, changes: %{phone: phone}, data: %__MODULE__{phones: phones, country: country}} = changeset) do
    if Validations.is_valid_phone?(phone, country) do
      # add the phone number to the list of phone numbers and update the changeset
      changeset |> put_change(:phones, [phone | phones]) |> put_change(:email, nil)
    else
      changeset
      # add error message to changeset phone
      |> add_error(:phone, "Failed. The phone number #{phone} has an invalid format or is invalid for your country.")
      # set the phone to nil
      |> put_change(:phone, nil)
    end # end of if
  end # end ov validate_phone_and_add_to_phones/1
  def validate_phon_and_add_to_phones(changeset), do: changeset

end
