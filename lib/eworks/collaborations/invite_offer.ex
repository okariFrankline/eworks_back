defmodule Eworks.Collaborations.InviteOffer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invite_offers" do
    field :asking_amount, :integer
    field :is_accepted, :boolean, default: false
    field :is_cancelled, :boolean, default: false
    field :is_pending, :boolean, default: false
    field :is_rejected, :boolean, default: false
    # belongs to one user
    belongs_to :user, Eworks.Collaborations.User, type: :binary_id
    # belongs to one invite
    belongs_to :invite, Eworks.Collaborations.Invite

    timestamps()
  end

  @doc false
  def changeset(invite_offer, attrs) do
    invite_offer
    |> cast(attrs, [
      :is_pending,
      :is_accepted,
      :is_rejected,
      :is_cancelled,
      :asking_mount
    ])
    |> validate_required([
      :asking_mount
    ])
    # ensure the user_id is given
    |> foreign_key_constraint(:user_id)
    # ensure the order id is given
    |> foreign_key_constraint(:order_id)
  end

end
