defmodule Eworks.Accounts.WorkProfile.PreviousHires do
  @moduledoc """
    Defines orders that have being assigned to a given and have being marked as
    complete, and paid for
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :owner, :string
    field :description, :string
    field :specialty, :string
    field :rating, :integer
    field :comment, :string
    # belongs to one user
    belongs_to :work_profile, Eworks.Accounts.WorkProfile, type: :binary_id
  end # end of the schema

end # end of the module
