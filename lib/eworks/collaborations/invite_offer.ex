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
    field :user_id, :binary_id
    field :invite_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(invite_offer, attrs) do
    invite_offer
    |> cast(attrs, [:asking_amount, :is_pending, :is_cancelled, :is_rejected, :is_accepted])
    |> validate_required([:asking_amount, :is_pending, :is_cancelled, :is_rejected, :is_accepted])
  end
  
end
