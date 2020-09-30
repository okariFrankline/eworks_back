defmodule Eworks.Collaborations.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Eworks.Utils.UniqueCode, as: Unique

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invites" do
    field :category, :string
    field :duration, :string
    field :deadline, :date
    field :payable_amount, :string,
    field :payable_schedule, :string,
    field :required_collaborators, :integer
    field :is_paid_for, :boolean, :string
    field :collaborators, {:array, :binary_id} # holds the ids of the people assigned as collaborators
    # virtual fields
    field :deadline_string_date, :string, virtual: true
    # order id for the order the invite is for
    field :order_id, :binary_id
    # belongs to one user who is a contractor
    belongs_to :work_profile, Eworks.Accounts.WorkProfile, type: :binary_id
    # has many inviation offers
    has_many :collaboration_offers, Eworks.Collaborations.CollaborationOffer
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
      :duration,
      :order_id,
      :category,
      :collaborators
    ])
  end

  @doc false
  def creation_changeset(invite, attrs) do
    changeset(invite, attrs)
    |> cast(attrs, [
      :deadline_string_date
    ])
    # ensure the title and invite type
    |> validate_required([
      :duration,
      :deadline_string_date,
      :category,
      :order_id
    ])
    # insert the verification code
    |> set_deadline()
    # ensure the user id is given
    |> foreign_key_constraint(:user_id)
  end # end of the creation_changeset/2

  @doc false
  def payment_changeset(invite, attrs) do
    changeset(invite, attrs)
    # ensure the payment info is providedd
    |> validate_required([
      :payable_amount,
      :payment_schedule,
      :required_collaborators
    ])
  end # end of payment changeset

  # function for setting the deadline date
  defp set_deadline_date(%Changeset{valid?: true, changes: %{deadline_string_date: s_date}} = changeset) do
    # get the date from the given string
    {:ok, date} = Date.from_iso8601(s_date)
    # put the date to the changeset
    changeset |> put_change(:deadline, date) |> put_change(:deadline_string_date, nil)
  end # end of set_deadline-date/1
  defp set_deadline_date(changeset), do: changeset

end # end of the module
