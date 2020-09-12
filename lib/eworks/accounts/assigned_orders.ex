defmodule Eworks.Accounts.Users.AssignedOrder do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # created_at and update_at
    timestamps()
  end # end of the schema

end # end of the module
