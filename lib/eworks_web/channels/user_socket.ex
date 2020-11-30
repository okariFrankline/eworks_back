defmodule EworksWeb.UserSocket do
  use Phoenix.Socket

  # alias the user struct
  alias Eworks.Accounts.{Session}
  alias Eworks.Repo
  import Ecto.Query, warn: false

  ## Channels
  channel "notification:*", EworksWeb.NotificationChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => "Bearer " <> token}, socket, _connect_info) do
    # get the user with the given id
    Session
    # filter only where the token is required
    |> where(token: ^token)
    # get one result from the dp
    |> Repo.one()
    # check if ther user exists or not
    |> case do
      # the session does not exist
      nil ->
        # deny the connection
        :error
      # the user exist
      session ->
        # get the account
        user = Repo.preload(session, [:user]).user
        # return the account
        {:ok, assign(socket, :current_user, user)}
    end # end of cond

    {:ok, socket}
  end # end of the connect function

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     EworksWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
