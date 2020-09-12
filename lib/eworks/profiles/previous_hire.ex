defmodule Eworks.Profiles.WorkProfile.PreviousHires do
  @moduledoc """
    Defines orders that have being assigned to a given and have being marked as
    complete, and paid for
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :category, :string
    field :description, :string
    field :order_type, :string
    field :specialty, :string
    field :title, :string
    field :rating, :integer
    field :comment, :string
    # belongs to one user
    belongs_to :work_profile, Eworks.Profiles.WorkProfile, type: :binary_id
  end # end of the schema

end # end of the module
