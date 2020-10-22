defmodule Eworks.Collaborations.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invites" do
    # category and specialty
    field :category, :string
    field :specialty, :string
    field :verification_code, :integer

    # deadline and required contractors
    field :deadline, :date
    field :required_collaborators, :integer
    field :show_more, :boolean, default: false

    # payment information
    field :payable_amount, :string
    field :payment_schedule, :string
    field :min_amount, :string, virtual: true
    field :max_amount, :string, virtual: true

    field :is_paid_for, :boolean, default: false
    field :is_cancelled, :boolean, default: false
    field :is_assigned, :boolean, default: false
    field :is_draft, :boolean, default: true

    field :collaborators, {:array, :binary_id} # holds the ids of the people assigned as collaborators
    field :description, :string
    # virtual fields
    field :deadline_string_date, :string, virtual: true
    # order id for the order the invite is for
    field :order_id, :binary_id
    # belongs to one user who is a contractor
    belongs_to :work_profile, Eworks.Accounts.WorkProfile, type: :binary_id
    # has many inviation offers
    has_many :collaboration_offers, Eworks.Collaborations.InviteOffer
    # created at and updated at
    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [
      :payable_amount,
      :deadline,
      :is_paid_for,
      :required_collaborators,
      :payment_schedule,
      :order_id,
      :category,
      :specialty,
      :collaborators,
      :description,
      :is_cancelled,
      :is_assigned,
      :verification_code,
      :show_more,
      :is_draft
    ])
  end

  @doc false
  def creation_changeset(invite, attrs) do
    changeset(invite, attrs)
    |> cast(attrs, [
      :category,
      :specialty
    ])
    # ensure the title and invite type
    |> validate_required([
      :category,
      :specialty
    ])
    # add the verification code
    |> put_verification_code()
    # ensure the user id is given
    |> foreign_key_constraint(:work_profile)
  end # end of the creation_changeset/2

  @doc false
  def category_changeset(invite, attrs) do
    changeset(invite, attrs)
    # ensure the title and invite type
    |> validate_required([
      :category,
      :specialty
    ])
  end # end of the creation_changeset/2


  @doc false
  def deadline_collaborators_required_changeset(invite, attrs) do
    changeset(invite, attrs)
    # cast teh deadline string
    |> cast(attrs, [
      :deadline_string_date
    ])
    # ensure the the deadline is given
    |> validate_required([
      :deadline_string_date,
      :required_collaborators
    ])
    # set the deadline
    |> set_deadline_date()
  end

  @doc false
  def description_changeset(invite, attrs) do
    changeset(invite, attrs)
    # ensure the descritpion is give
    |> validate_required([
      :description
    ])
  end

  @doc false
  def payment_changeset(invite, attrs) do
    changeset(invite, attrs)
    # cast
    |> cast(attrs, [
      :min_amount,
      :max_amount
    ])
    # ensure the payment info is providedd
    |> validate_required([
      :min_amount,
      :max_amount,
      :payment_schedule,
    ])
    # validat the payment amounts
    |> validate_payment_amounts()
    # add the payable amount
    |> add_payment_range()
  end # end of payment changeset

  # function for setting the deadline date
  defp set_deadline_date(%Changeset{valid?: true, changes: %{deadline_string_date: s_date}} = changeset) do
    # get the date from the given string
    {:ok, date} = Date.from_iso8601(s_date)
    # put the date to the changeset
    changeset |> put_change(:deadline, date) |> put_change(:deadline_string_date, nil)
  end # end of set_deadline-date/1
  defp set_deadline_date(changeset), do: changeset

  # function for validating the payment amounts
  defp validate_payment_amounts(%Changeset{valid?: true, changes: %{min_amount: min_payment, max_amount: max_payment}} = changeset) do
    # check if the max amount is more than the min amount
    if String.to_integer(min_payment) < String.to_integer(max_payment) do
      # return the changeset as is
      changeset
    else
      # add error on the max amount
      changeset |> add_error(:max_amount, "Field. Maximum amount must be more than the minimum amount.")
    end # end of if
  end # end of validate_payment_amounts
  defp validate_payment_amounts(changeset), do: changeset

  # function for adding the payment range
  defp add_payment_range(%Changeset{valid?: true, changes: %{min_amount: m_payment, max_amount: x_payment}} = changeset) do
    changeset
    # add the string version of the payment using the minimum and maximum number
    |> put_change(:payable_amount, "#{m_payment} - #{x_payment}")
  end # end of add_payment_range
  defp add_payment_range(changeset), do: changeset

  # fuction for putting a verification code
  defp put_verification_code(%Changeset{valid?: true} = changeset) do
    changeset
    # add the verification code
    |> put_change(:verification_code, Enum.random(100_00..999_999))
  end # end of put verification code
  defp put_verification_code(changeset), do: changeset

end # end of the module
