defmodule Eworks.Requests.DirectHire do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "direct_hires" do
    field :is_accepted, :boolean, default: false
    field :is_rejected, :boolean, default: false
    # order for which this direct order if for
    field :order_id, :binary_id
    field :is_pending, :boolean, default: true

    # the contractors for whom the request is intended for
    belongs_to :work_profile, Eworks.Accounts.WorkProfile, type: :binary_id
    # the owner of the direct hire
    belongs_to :user, Eworks.Accounts.User, type: :binary_id

    timestamps()
  end # end of direct_hires

  @doc false
  def changeset(direct_hire, attrs) do
    direct_hire
    |> cast(attrs, [
      :is_accepted,
      :is_rejected,
      :order_id,
      :is_pending
    ])
    # foregin key constraint
    |> foreign_key_constraint(:user)
    # ensure the work_profile id is given
    |> foreign_key_constraint(:work_profile)
  end
end
