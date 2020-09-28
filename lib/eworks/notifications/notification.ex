defmodule Eworks.Notifications.Notification do
  @moduledoc """
    Holds the notifications for a given user.
    Notification.asset_type can only be a string with values of either:
    Order, OrderOffer, User
  """
  use Ecto.Schema
  import Ecto.Changeset

  @asset_types %{
    order: "Order",
    order_offer: "Order Offer",
    user: "User"
  }

  @notification_types %{
    offer_acceptance: "Order Offer Acceptance",
    offer_rejection: "Order Offer Rejection",
    order_assignment: "Order Assignment",
    order_completion: "Order Completion",
    order_payment: "Order Payment",
    account_suspension: "Account Suspension",
    account_upgrade: "Account Upgrade",
    order_acceptance: "Order Acceptance",
    order_rejection: "Order Rejection"
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notification" do
    field :asset_id, :binary_id
    field :asset_type, :string
    field :is_viewed, :boolean, default: false
    field :message, :string
    field :notification_type, :string
    # belongs to one user
    field :user, Eworks.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    # set the correct value for the asset type
    |> Map.update(:asset_type, fn value -> Map.get(@asset_types, value) end)
    # set the correct value for the notification type
    |> Map.update(:notification_type, fn value -> Map.get(@notification_types, values) end)
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
