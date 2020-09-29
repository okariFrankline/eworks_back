defmodule Eworks.Accounts.AssignedOrder do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :attachments, Eworks.Uploaders.OrderAttachment.Type
    field :category, :string
    field :deadline, :date
    field :description, :string
    field :duration, :string
    field :order_type, :string
    field :is_assigned, :boolean, default: false
    field :is_complete, :boolean, default: false
    field :is_paid_for, :boolean, default: false
    field :is_verified, :boolean, default: false
    field :payable_amount, :string
    field :payment_schedule, :string
    field :required_contractors, :integer
    field :specialty, :string
    field :rating, :integer
    field :comment, :string
    # belongs to one user
    belongs_to :work_profile, Eworks.Accounts.User, type: :binary_id
    # created_at and update_at
    timestamps()
  end # end of the schema

end # end of the module
