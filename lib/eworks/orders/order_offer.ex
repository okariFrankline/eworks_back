defmodule Eworks.Orders.OrderOffer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_offers" do
    field :asking_mount, :string
    field :is_accepted, :boolean, default: false
    field :is_pending, :boolean, default: true
    field :is_rejected, :boolean, default: false
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
      :is_accepted,
      :is_rejected,
      :asking_mount
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
