defmodule Eworks.API.Utils do
  @moduledoc """
    Provides utility functions for the api module
  """

  def upload_url(url) do
    if url, do: url |> String.split("?") |> List.first(), else: nil
  end

  @doc """
    Function for providing a name for uploaded files
  """
  def new_upload_name(%Plug.Upload{filename: file_name} = file) do
    # generate a unique name
    uuid = UUID.uuid4()
    # get the current timestamp
    current_date = DateTime.utc_now() |> DateTime.to_iso8601() |> String.replace(":", "_")
    # return the file name
    file_name = "#{uuid}_#{current_date}.#{Path.extname(file_name)}"
    # update the file
    Map.update!(file, :filename, fn _ -> file_name end)
  end # end of new upload name

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
