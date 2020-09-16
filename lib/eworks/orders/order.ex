defmodule Eworks.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Eworks.Utils.UniqueCode, as: Unique

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :attachments, {:array, :string}
    field :category, :string
    field :deadline, :date
    field :description, :string
    field :duration, :string
    field :order_type, :string
    field :is_assigned, :boolean, default: false
    field :is_complete, :boolean, default: false
    field :is_paid_for, :boolean, default: false
    field :is_verified, :boolean, default: false
    field :max_payment, :string, virtual: true
    field :min_payment, :string, virtual: true
    field :payable_amount, :string
    field :payment_schedule, :string
    field :required_contractors, :integer
    field :specialty, :string
    field :is_draft, :boolean, default: true
    field :verification_code, :integer
    field :rating, :integer
    field :comment, :string
    field :assigned_order_id, :binary_id
    # belongs to one user
    belongs_to :user, Eworks.Orders.User, type: :binary_id
    # has many assignees
    has_many :assignees, __MODULE__.Assignee
    # has many order_offers
    has_many :order_offers, Eworks.Orders.OrderOffer


    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :description,
      :is_verified,
      :is_assigned,
      :is_complete,
      :is_paid_for,
      :duration,
      :deadline,
      :category,
      :required_contractors,
      :specialty,
      :attachments,
      :is_draft,
      :verification_code,
      :order_type,
      :comment,
      :rating,
      :payable_amount,
      :payment_schedule
    ])
  end # end of changeset

  @doc false
  def creation_changeset(order, attrs) do
    changeset(order, attrs)
    # cast the min and max payment
    |> cast(attrs, [
      :category,
      :specialty,
    ])
    |> validate_required([
      :category,
      :specialty,
    ])
    # insert the order verification code
    |> add_verification_code()
    # ensure the order has an owner
    |> foreign_key_constraint(:user_id)
  end # end of the creation_changeset

  @doc false
  def rating_comment_changeset(order, attrs) do
    changeset(order, attrs)
    |> validate_required([
      :rating,
      :comment
    ])
  end # end of the rating_comment_changeset

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
  def type_changeset(order, attrs) do
    changeset(order, attrs)
    # ensure the fields are given
    |> validate_required([
      :order_type,
      :required_contractors
    ])
  end # end of the category_speciality_changeset/2

  @doc false
  def duration_changeset(order, attrs) do
    changeset(order, attrs)
    # ensure the fields are given
    |> validate_required([
      :deadline,
      :duration
    ])
  end # end of type_duration_changeset

  @doc false
  def description_changeset(order, attrs), do: changeset(order, attrs) |> validate_required([:description])

  # function for adding the verification code
  defp add_verification_code(%Changeset{valid?: true} = changeset) do
    # add a unique number to the changeset
    changeset |> put_change(:verification_code, Unique.generate())
  end # end of add-verification_code/1
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
