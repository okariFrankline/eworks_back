defmodule Eworks.Profiles.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Eworks.Utils.Validations

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_profiles" do
    field :city, :string
    field :country, :string
    field :email, :string, virtual: true
    field :emails, {:array, :string}
    field :phone, :string, virtual: true
    field :phones, {:array, :string}
    field :profile_pic, :string
    field :skills, {:array, :string}
    belongs_to :user, Eworks.Profiles.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :country,
      :city,
      :emails,
      :phones,
      :profile_pic,
      :skills
    ])
  end

  @doc false
  def skills_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure the skiils is given
    |> validate_required([
      :skills
    ])
    # add the skills to the skills already in the changeset
    |> add_to_skills()
  end # end of the skills_changeset/2

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
      :country,
      :city
    ])
  end # end of the location changeset

  # function for adding the skills to the changeset
  def add_to_skills(%Changeset{valid?: true, changes: %{skills: new_skills}, data: %__MODULE__{skills: saved_skills}} = changeset) do
    # check that any of the elements in the new skills is not in the saved skills
    to_save_skills = Enum.map(new_skills, fn skill ->
      # return the skill if its not in the saved skilled
      if not Enum.member?(saved_skills, skill), do: skill
    end)
    # check if the skills to save have any value
    if to_save_skills !== [] do
      # add the new skiils to the already saved skills
      changeset |> put_change(:skills, [to_save_skills | saved_skills])
    else
      # set the changeset action to nil to prevent any update
      changeset |> put_change(:action, nil)
    end # end of if
  end # end of add_to_skills/1
  def add_to_skills(changeset), do: changeset

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
