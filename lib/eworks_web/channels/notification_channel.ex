defmodule EworksWeb.NotificationChannel do
  use Phoenix.Channel

  alias Eworks.Repo
  import Ecto.Query, warn: false
  alias Eworks.Notifications.Notification


  @doc """
    Allows a user to join the channel "user:user_id"
  """
  def join("notification:" <> user_id, _params, %{assigns: %{current_user: user}} = socket) do
    # check if user is given
    if user != nil and user.id == user_id do
      send(self(), :after_join)
      # allow connection
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end # end of if
  end # end of assignsfor joining the channel

  @doc """
    Handle after join message that loads all the user's notifications and sends it to
    the client's sockets
  """
  def handle_info(:after_join, %{assigns: %{current_user: user}} = socket) do
    # preload all the notification for the current user and only for notification that have not yet being viewed
    user = Repo.preload(user, [notifications: from(notification in Notification, where: notification.is_viewed == false)])
    # push the notifications to the client
    push(socket, "notification::unviewed_notifications", %{notifications: user.notifications})
    # return a no reply
    {:noreply, socket}
  end # end of handling after join function.

  @doc """
    Handle out
  """
  def handle_out("notificcation::" <> type, payload, socket) do
    IO.inspect(payload)
    {:noreply, socket}
  end # end of handle_out

end # end of the module for user channels
