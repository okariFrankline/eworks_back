defmodule Eworks.Collaborations.Invite.Order do
  @moduledoc """
    Defines an order for which a given invite is for
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    # attachments for the order
    field :attachments, {:array, :string}
    # category for the order
    field :category, :string
    # description for the invite
    field :description, :string
    # order type for the order for which the invite is for
    field :order_type, :string
    # the specialty of the order for which the invite is for
    field :specialty, :string
    # title of the order
    field :title, :string
    # belongs to one user
    belongs_to :invite, Eworks.Collaborations.Invite, type: :binary_id
  end # end of the schema

end # end of the module
