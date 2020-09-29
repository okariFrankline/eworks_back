defmodule EworksWeb.UserSocket do
  use Phoenix.Socket

  alias EworksWeb.Authentication.Guardian

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
  def connect(%{"token" => token}, socket, _connect_info) do
    # authenticate to ensure that the user is currently logged in
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        # get the resource(current user) with the token
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            # set the current user to the assigns
            {:ok, assign(socket, :current_user, user)}

          {:error, _reason} ->
            # return error denying the connection
            :error
        end # end of getting the claims from the token
    end # end of verifying the token that has being given
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
