defmodule Eworks.Collaborations.User do
  @moduledoc """
    Defines a user for the orders module
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    # has many invites
    has_many :invites, Eworks.Collaborations.Invite
    # has many invite_offers
    has_many :invite_offers, Eworks.Collaborations.InviteOffer
  end # end of users scham

end # end of User module
