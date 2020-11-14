defmodule Eworks.Notifications.Notification do
  @moduledoc """
    Holds the notifications for a given user.
    Notification.asset_type can only be a string with values of either:
    Order, OrderOffer, User
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :message, :asset_type, :asset_id, :notification_type, :is_viewed]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :asset_id, :binary_id
    field :asset_type, :string
    field :is_viewed, :boolean, default: false
    field :message, :string
    field :notification_type, :string
    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    # cast the values
    |> cast(attrs, [
      :notification_type,
      :message,
      :is_viewed,
      :asset_type,
      :asset_id
    ])
    |> validate_required([
      :notification_type,
      :message,
      :asset_type,
      :asset_id
    ])
    # ensure the user id is given
    |> foreign_key_constraint(:user_id)
  end
end
