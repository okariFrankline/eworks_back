defmodule Eworks.Collaborations.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Eworks.Utils.UniqueCode, as: Unique

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invites" do
    field :collaborators_needed, :integer
    field :deadline, :date
    field :duration, :string
    field :description, :string
    field :is_paid_for, :boolean, default: false
    field :is_verified, :boolean, default: false
    field :payable_amount, :string
    field :min_payment, :integer, virtual: true
    field :max_payment, :integer, virtual: true
    field :payment_schedule, :string
    field :title, :string
    field :verification_code, :integer
    field :invite_type, :string
    field :is_draft, :boolean, default: true
    # belong to one user
    belongs_to  :user, Eworks.Collaborations.User, type: :binary_id
    # has one order
    has_one :order, __MODULE__.Order
    # created at and updated at
    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [
      :title,
      :payable_amount,
      :deadline,
      :is_verified,
      :verification_code,
      :is_paid_for,
      :collaborators_needed,
      :is_draft,
      :payment_schedule,
      :description,
      :duration
    ])
  end

  @doc false
  def creation_changeset(invite, attrs) do
    changeset(invite, attrs)
    # ensure the title and invite type
    |> validate_required([
      :title,
      :invite_type,
      :collaborators_needed
    ])
    # insert the verification code
    |> add_verification_code()
    # ensure the user id is given
    |> foreign_key_constraint(:user_id)
  end # end of the creation_changeset/2

  @doc false
  def duration_changeset(invite, attrs) do
    changeset(invite, attrs)
    # ensure the title and invite type
    |> validate_required([
      :deadline,
      :duration
    ])
    # insert the verification code
    |> add_verification_code()
  end # end of the creation_changeset/2

 @doc false
 def payment_changeset(order, attrs) do
  changeset(order, attrs)
  # cast the min and max payments
  |> cast(attrs, [
    :min_payment,
    :max_payment
  ])
  # ensure that the min, max and payment schedule are given
  |> validate_required([
    :min_payment,
    :max_payment,
    :payment_schedule
  ])
  # ensure the minimum payment is less than the maximum payment
  |> validate_payment_amounts()
  # add the payabale amount
  |> add_payment_range()
end # end of the payment changeset

@doc false
def description_changeset(invite, attrs) do
  changeset(invite, attrs)
  # ensure the description is given
  |> validate_required([
    :description
  ])
end # end of description_changeset/2

  # function for adding the verification ocde
  defp add_verification_code(%Changeset{valid?: true} = changeset) do
    changeset
    # add the verification code
    |> put_change(:verification_code, Unique.generate())
  end # end of add_verification_code/1
  defp add_verification_code(changeset), do: changeset

  # function for adding the payment range
  defp add_payment_range(%Changeset{valid?: true, changes: %{min_payment: m_payment, max_payment: x_payment}} = changeset) do
    changeset
    # add the string version of the payment using the minimum and maximum number
    |> put_change(:payable_amount, "#{m_payment} - #{x_payment}")
  end # end of add_payment_range
  defp add_payment_range(changeset), do: changeset

  # function for validating the payment amounts
  defp validate_payment_amounts(%Changeset{valid?: true, changes: %{min_payment: min_payment, max_payment: max_payment}} = changeset) do
    # check if the max amount is more than the min amount
    if min_payment < max_payment do
      # return the changeset as is
      changeset
    else
      # add error on the max amount
      changeset |> add_error(:max_amount, "Field. Maximum amount must be more than the minimum amount.")
    end # end of if
  end # end of validate_payment_amounts
  defp validate_payment_amounts(changeset), do: changeset
end # end of the module
