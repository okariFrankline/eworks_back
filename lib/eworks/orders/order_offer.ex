defmodule Eworks.Orders.OrderOffer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_offers" do
    field :asking_amount, :string
    # has indicated whether the owner of the offer has accepted to take the offer.
    field :has_accepted_order, :boolean, default: false
    field :has_rejected_order, :boolean, default: false
    field :is_pending, :boolean, default: true
    field :is_cancelled, :boolean, default: false
    field :is_rejected, :boolean, default: false
    field :is_accepted, :boolean, default: false
    field :order_accepting_pending, :boolean, default: true
    # owner of the offer
    # field :owner_name, :string
    # field :owner_profile_pic, :string,
    # field :owner_job_success, :integer,
    # field :owner_about, :string
    # field :owner_rating, :string

    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # belongs to the order
    belongs_to :order, Eworks.Orders.Order, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(order_offer, attrs) do
    order_offer
    |> cast(attrs, [
      :is_pending,
      :has_accepted_order,
      :is_rejected,
      :asking_amount,
      :is_accepted,
      :is_cancelled,
      :has_rejected_order,
      :order_accepting_pending
    ])
    |> validate_required([
      :asking_mount
    ])
    # ensure the user_id is given
    |> foreign_key_constraint(:user_id)
    # ensure the order id is given
    |> foreign_key_constraint(:order_id)
  end

end # end of module
