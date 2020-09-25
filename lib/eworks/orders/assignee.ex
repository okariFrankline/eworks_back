defmodule Eworks.Orders.Order.Assignee do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    # first name
    field :full_name, :string
    # one assignee can for a given order
    belongs_to :order, Eworks.Orders.Order, type: :binary_id
  end # end of users schema

end # end of module
