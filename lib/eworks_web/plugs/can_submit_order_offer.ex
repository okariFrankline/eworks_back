defmodule EworksWeb.Plugs.CanSubmitOrderOffer do
  @behaviour Plug

  import Plug.Conn
  alias Eworks.Repo
  alias Phoenix.Controller

  # init function
  def init(opts), do: opts

  # call functions
  def call(%{assigns: %{current_user: user}} = conn, _opts) do
    # check if the current user is a practise
    if user.user_type == "Independent Controller" do
      # return the conn
      conn
    else # the user is not a practise
      # preload the user's work profile
      user = user |> Repo.preload([:work_profile])
      # check if the work profile is there and that the upgrade session has not expired
      cond do
        # check if the user has a work profile
        user.work_profile == nil ->
          # return the conn
          conn
          # put the status to bad request
          |> put_status(:forbidden)
          # put the error view
          |> Controller.put_view(EworksWeb.ErrorView)
          # render the is client.json
          |> Controller.render("is_client.json", message: "Failed. You have a client account and it does not have a one time upgrade")
          # halt the processing of the other conn
          |> halt()

        # the user has a work profile but eh upgrade session has expired
        user.work_profile != nil and user.work_profile.has_upgrade_expired ->
          # return the conn
          conn
          # put the status to bad request
          |> put_status(:forbidden)
          # put the error view
          |> Controller.put_view(EworksWeb.ErrorView)
          # render the is client.json
          |> Controller.render("upgrade_expired.json", %{expiry_date: user.work_profile.upgrade_expiry_date})
          # halt the processing of the other conn
          |> halt()

        # the user has a profile and the upgrade has not expired
        true ->
          # return conn
          conn
      end # end of cond
    end # end of if for checking the user type
  end # end of conn
end # end of is upgraded client
