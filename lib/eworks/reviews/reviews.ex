defmodule Eworks.Reviews.Review do
  @moduledoc """
    Holds the review for a giver user who is contractor made by an the owner
    of an order that has being assigned to the given user
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    # rating
    field :rating, :float
    # comment
    field :comment, :string
    # user id
    field :user_id, :binary_id
    # belongs to a given order
    belongs_to :order, Eworks.Orders.Order, type: :binary_id
  end # end of the defintion of the schema

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [
      :user_id,
      :comment,
      :rating
    ])
    |> validate_required([
      :comment,
      :rating
    ])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:order_id)
  end
end # end of review
