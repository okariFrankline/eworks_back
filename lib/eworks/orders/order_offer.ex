defmodule Eworks.Orders.OrderOffer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_offers" do
    field :asking_amount, :string
    # has indicated whether the owner of the offer has accepted to take the offer.
    field :has_accepted_order, :boolean, default: false
    field :is_pending, :boolean, default: true
    field :is_cancelled, :boolean, default: false
    field :is_rejected, :boolean, default: false
    field :is_accepted, :boolean, default: false
    field :order_id, :binary_id

    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id

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
      :is_cancelled
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
