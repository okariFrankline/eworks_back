defmodule Eworks.NotificationsTest do
  use Eworks.DataCase

  alias Eworks.Notifications

  describe "notification" do
    alias Eworks.Notifications.Notification

    @valid_attrs %{asset_id: "some asset_id", asset_type: "some asset_type", is_viewed: true, message: "some message", notification_type: "some notification_type"}
    @update_attrs %{asset_id: "some updated asset_id", asset_type: "some updated asset_type", is_viewed: false, message: "some updated message", notification_type: "some updated notification_type"}
    @invalid_attrs %{asset_id: nil, asset_type: nil, is_viewed: nil, message: nil, notification_type: nil}

    def notification_fixture(attrs \\ %{}) do
      {:ok, notification} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_notification()

      notification
    end

    test "list_notification/0 returns all notification" do
      notification = notification_fixture()
      assert Notifications.list_notification() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Notifications.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      assert {:ok, %Notification{} = notification} = Notifications.create_notification(@valid_attrs)
      assert notification.asset_id == "some asset_id"
      assert notification.asset_type == "some asset_type"
      assert notification.is_viewed == true
      assert notification.message == "some message"
      assert notification.notification_type == "some notification_type"
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{} = notification} = Notifications.update_notification(notification, @update_attrs)
      assert notification.asset_id == "some updated asset_id"
      assert notification.asset_type == "some updated asset_type"
      assert notification.is_viewed == false
      assert notification.message == "some updated message"
      assert notification.notification_type == "some updated notification_type"
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_notification(notification, @invalid_attrs)
      assert notification == Notifications.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end
end
