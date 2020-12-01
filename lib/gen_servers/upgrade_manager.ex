defmodule Eworks.Upgrade.Manager do
  @moduledoc """
    GenServer module that is responsible for ensuring that all upgraded
    client accounts that are expired are cancelled
  """
  use GenServer
  import Ecto.Query, warn: false
  alias Eworks.Accounts.{User}
  alias Eworks.Notifications
  alias EworksWeb.Endpoint

  @repo Eworks.Repo
  @paginator_limit 10

  @doc """
    start link function
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end # end of start_link


  def init(_) do
    # schedule the next time the genserver will run
    schedule_next_start()
    # return the reult
    {:ok, %{}}
  end # end of init function

  # handle info starting
  def handle_info({:start, next_cursor}, state) do
    # load the first batch of users
    query = from(
      user in User,
      # ensure the user us a client
      where: user.user_type == "Client" and user.is_upgraded_contractor == true,
      # join the work profile
      left_join: profile in assoc(user, :work_profile),
      # ensure the expiry date of upgrade us today
      where: profile.upgrade_expiry_date == ^DateTime.to_date(Timex.now()) and profile.has_upgrade_expired == false,
      # order by
      order_by: [asc: user.inserted_at, asc: user.id],
      # preload the work profile
      preload: [work_profile: profile]
    )

    # load the users
    page = if is_nil(next_cursor) do
      @repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: @paginator_limit)
    else
      @repo.paginate(query, after: next_cursor, cursor_fields: [:inserted_at, :id], limit: @paginator_limit)
    end # end of getting the page

    # update the state
    state = Map.put_new(state, :next_cursor, page.metadata.after) |> Map.put_new(:to_process, page.entries)
    # send self a message to start processing the users
    send(self(), {:begin_canceling_upgrades, state})
    # return the result
    {:noreply, state}
  end # end of handle info for start

  #def handle_info(:begin_canceling_upgrades, %{next_cursor: _cursor, to_process: users}) when users == [], do: reschedule_canceling_task()
  def handle_info({:begin_canceling_upgrades, %{next_cursor: cursor, to_process: users}}, state) do
    # for each user, cancel the upgrade
    Enum.each(users, fn user -> cancel_upgrade(user) end)
    # check if the cursor is nil
    if is_nil(cursor) do
      # return the no reply by setting the to process to an empty list
      {:noreply, Map.put(state, :to_process, [])}
    else
      # send self a message to get more users to process
      send(self(), {:start, cursor})
      # return the state
      {:noreply, state}
    end
  end # end of handel_info

  # function for scheduling the next job after 24 hours
  defp schedule_next_start, do: Process.send_after(self(), {:start, nil}, 24 * 60 * 60 * 100)
  # function for canceling the upgrade
  defp cancel_upgrade(%User{work_profile: profile} = user) do
    Ecto.Changeset.change(profile, %{
      has_upgraded_expired: true
    })
    # update the work profile
    |> @repo.update!()
    # start a task to create notification to the owner of the user
    Task.start(fn ->
      {:ok, notification} = Notifications.create_notification(%{
        user_id: user.id,
        asset_id: profile.id,
        asset_type: "User",
        message: "Dear #{user.full_name}, your client account's One Time Upgrade has expired. To continue being able to submit more offers as a client, please upgrade your account again.",
        notification_type: "One Time Upgrade Expiration"
      })
      # send a notification to the user
      Endpoint.broadcast!("user:#{user.id}", "new_notification", %{notification: notification})
    end)
  end # end of cancel_upgrade
end # end of Upgrade.Manger
