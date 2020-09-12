defmodule Eworks.Orders.User do
  @moduledoc """
    Defines a user for the orders module
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    # has many orders
    has_many :orders, Eworks.Orders.Order
    # has many order offers
    has_many :order_offers, Eworks.Orders.OrderOffer
  end # end of users scham

end # end of User module
