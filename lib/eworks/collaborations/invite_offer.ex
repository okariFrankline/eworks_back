defmodule Eworks.Collaborations.InviteOffer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invite_offers" do
    field :is_accepted, :boolean, default: false
    field :is_cancelled, :boolean, default: false
    field :is_pending, :boolean, default: false
    field :is_rejected, :boolean, default: false
    field :has_accepted_invite, :boolean, default: false
    field :asking_amount, :integer
    field :show_more, :boolean, default: false
    # owner information
    field :owner_name, :string
    field :owner_rating, :float
    field :owner_about, :string
    field :owner_profile_pic, :string
    field :owner_job_success, :float
    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # belongs to one invite
    belongs_to :invite, Eworks.Collaborations.Invite, type: :binary_id

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
      :has_accepted_invite,
      :owner_name,
      :owner_rating,
      :owner_about,
      :owner_profile_pic,
      :owner_job_success,
      :asking_amount,
      :show_more
    ])
    # ensure the user_id is given
    |> foreign_key_constraint(:user_id)
    # ensure the order id is given
    |> foreign_key_constraint(:invite_id)
  end

end
