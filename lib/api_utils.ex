defmodule Eworks.API.Utils do
  @moduledoc """
    Provides utility functions for the api module
  """

  def upload_url(url) do
    if url, do: url |> String.split("?") |> List.first(), else: nil
  end

  # render_notification
  def render_notification(notification) do
    %{
      user_id: notification.user_id,
      asset_type: notification.asset_type,
      asset_id: notification.id,
      message: notification.message
    }
  end # end of notificaiton

end # end of module
