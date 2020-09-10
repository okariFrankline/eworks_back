defmodule Eworks.User.AssignedOrder do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "assigned_orders" do
    # has one base order
    # base order if an order from which the currenctyl assigned order is built frim
    has_one :base_order, Eworks.Orders.Order
    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # created_at and update_at
    timestamps()
  end # end of the schema

end # end of the module
