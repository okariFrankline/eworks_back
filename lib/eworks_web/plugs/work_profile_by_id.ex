defmodule EworksWeb.Plugs.WorkProfileById do
  @moduledoc """
    Returns the work profile of a given user and puts it in the conn
  """
  @behaviour Plug
  import Plug.Conn

  alias Eworks.{Repo, Accounts}

  # init function
  def init(opts), do: opts

  # call function
  def call(%{assigns: %{current_user: user}} = conn, _opts) do
    # get user's work profile
    user = user |> Repo.preload([:work_profile])
    # check if the work profile is given
    case user.work_profile do
      # work profile dound
      %Accounts.WorkProfile{} = work_profile ->
        # put the work profile in the assigns
        assign(conn, :Work_profile, work_profile)

      # the user has no work_profile
      _ ->
        conn
        # render work_profile_not_found
        |> send_resp(:not_found, "Work Profile Not Found!")
        # halt the processing of the request
        |> halt()
    end # end of checking if the order is available
  end # end of call

end # end of module
