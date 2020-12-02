defmodule Eworks.Orders.Order do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @description "
    This is a draft order project that is complete and is yet to be verified. Please edit the order in order to begin
    receiving offers from some of the best professional registered on the platform. Always keep in mind that, you,
    the client are always in control of the payment rate and the entire hiring process (including how and when the payment will be made).
    Alternatively, you can delete this order and remove it from your list of orders.
  "

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :attachments, Eworks.Uploaders.OrderAttachment.Type
    field :category, :string
    field :deadline, :date
    field :description, :string
    field :duration, :string
    field :order_type, :string
    field :already_assigned, :integer
    field :accepted_offers, :integer
    field :is_assigned, :boolean, default: false
    field :is_complete, :boolean, default: false
    field :is_paid_for, :boolean, default: false
    field :is_verified, :boolean, default: false
    field :is_cancelled, :boolean, default: false
    field :payable_amount, :string
    field :payment_schedule, :string
    field :required_contractors, :integer
    field :specialty, :string
    field :is_draft, :boolean, default: true
    field :verification_code, :integer
    field :rating, :integer
    field :comment, :string
    field :show_more, :boolean, default: false
    field :is_public, :boolean, default: false
    # holds the ids of user's that have tagged this order.
    field :tags, {:array, :binary_id}
    # virtual fields
    field :max_payment, :string, virtual: true
    field :min_payment, :string, virtual: true
    field :deadline_string_date, :string, virtual: true
    field :owner_name, :string
    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # has many assignees
    field :assignees, {:array, :binary_id}
    field :paid_assignees, {:array, :binary_id}
    # has many reviews
    has_many :reviews, Eworks.Reviews.Review
    # has many order_offers
    has_many :order_offers, Eworks.Orders.OrderOffer
    # has one direct hire request
    has_one :direct_hire, Eworks.Requests.DirectHire


    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
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
      :is_draft,
      :verification_code,
      :order_type,
      :comment,
      :rating,
      :payable_amount,
      :payment_schedule,
      :already_assigned,
      :accepted_offers,
      :assignees,
      :tags,
      :show_more,
      :owner_name,
      :is_public,
      :is_cancelled,
      :paid_assignees
    ])
    # cast teh changeset
    |> cast_attachments(attrs, [
      :attachments
    ])
  end # end of changeset

  @spec attachments_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def attachments_changeset(order, attrs) do
    changeset(order, attrs)
    # ensure attachments is given
    |> validate_required([
      :attachments
    ])
  end # end of attachment changeset

  @spec creation_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          map
        ) :: Ecto.Changeset.t()
  @doc false
  def creation_changeset(order, attrs) do
    # add the default description to the attrs
    attrs = Map.put(attrs, "description", @description)
    # get the changeset
    changeset(order, attrs)
    # ensure the category and the specialty are given
    |> validate_required([
      :category,
      :specialty
    ])
    # insert the order verification code
    |> put_verification_code()
    # ensure the order has an owner
    |> foreign_key_constraint(:user_id)
  end # end of the creation_changeset

  @spec category_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def category_changeset(order, attrs) do
    changeset(order, attrs)
    # ensure the category and the specialty are given
    |> validate_required([
      :category,
      :specialty
    ])
  end # end of the creation_changeset

  @spec rating_comment_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def rating_comment_changeset(order, attrs) do
    changeset(order, attrs)
    |> validate_required([
      :rating,
      :comment
    ])
  end # end of the rating_comment_changeset

  @spec payment_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
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

  @spec type_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def type_changeset(order, attrs) do
    changeset(order, attrs)
    # ensure the fields are given
    |> validate_required([
      :order_type,
      :required_contractors
    ])
  end # end of the category_speciality_changeset/2

  @spec duration_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def duration_changeset(order, attrs) do
    changeset(order, attrs)
    # cast the deadline_string_date
    |> cast(attrs, [
      :deadline_string_date
    ])
    # ensure the fields are given
    |> validate_required([
      :deadline_string_date,
      :duration
    ])
    # set the date
    |> set_deadline_date()
  end # end of type_duration_changeset

  @spec description_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def description_changeset(order, attrs), do: changeset(order, attrs) |> validate_required([:description])

  # function for setting the deadline date
  defp set_deadline_date(%Changeset{valid?: true, changes: %{deadline_string_date: s_date}} = changeset) do
    # get the date from the given string
    {:ok, date} = Date.from_iso8601(s_date)
    # put the date to the changeset
    changeset |> put_change(:deadline, date) |> put_change(:deadline_string_date, nil)
  end # end of set_deadline-date/1
  defp set_deadline_date(changeset), do: changeset

  # fuction for putting a verification code
  defp put_verification_code(%Changeset{valid?: true} = changeset) do
    changeset
    # add the verification code
    |> put_change(:verification_code, Enum.random(100_00..999_999))
  end # end of put verification code
  defp put_verification_code(changeset), do: changeset

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
    if String.to_integer(min_payment) < String.to_integer(max_payment) do
      # return the changeset as is
      changeset
    else
      # add error on the max amount
      changeset |> add_error(:max_amount, "Field. Maximum amount must be more than the minimum amount.")
    end # end of if
  end # end of validate_payment_amounts
  defp validate_payment_amounts(changeset), do: changeset

end # end of the module
