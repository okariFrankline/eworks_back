defmodule Eworks.Requests.API do
  @moduledoc """
    Defines api functions for handling business logic for requests
  """
  import Ecto.Query, warn: false
  alias Eworks.{Repo, Notifications, Accounts, Orders, Requests}
  alias Eworks.Accounts.{User}
  alias Eworks.Requests.{DirectHire}
  alias Eworks.Utils.{NewEmail, Mailer}
  alias EworksWeb.Endpoint

  @doc """
    Returns a list of direct hires for a user
  """
  def list_direct_hires(%User{} = user) do
    # query for getting the direct hires
    query = from(
      # get the profile
      from hire in Requests.DirectHire,
      # ensure hte invite is not rejected and also not cancelled
      where: hire.is_rejected == false and hire.is_cancelled == false,
      # join the order
      join: order in assoc(hire, :order),
      # preload the invite and the offer
      preload: [order: order]
    )
    # get the direct hires made to this user
    hires = Repo.preload(user, [work_profile: [direct_hires: query]]).work_profile.direct_hires

    IO.inspect(hires)
    # return the hires
    {:ok, hires}
  end # end of list direct hires

  @doc """
    creaetes a new direct hire request
  """
  def create_new_direct_hire_request(%User{} = user, order_id, recipient_id) do
    # ensure that the recipient exist
    recipient = Accounts.get_user!(recipient_id) |> Repo.preload(:work_profile)
    # ensure the user is not suspended
    if not recipient.is_suspended do
      # create a new request
      hire = user |> Ecto.build_assoc(:direct_hires, %{work_profile_id: recipient.work_profile.id, order_id: order_id}) |> Repo.insert!()
      # start a task to send the owner of the request a notification throught he email and websocket
      Task.start(fn ->
        # message
        message = "#{user.full_name} has made a direct hire request for you to work on their order. Please review the order and respond promptly."
        # create a new email
        NewEmail.new_email_notification(recipient, "New Direct Hire Request", "#{message} \n Please Login to view details.")
        # send the email
        |> Mailer.deliver_later()

        # create a new notification
        {:ok, notification} = Notifications.create_notification(%{
          user_id: recipient.id,
          asset_type: "Direct Hire",
          notification_type: "Direct Hire Request",
          asset_id: hire.id,
          message: message
        })
        # send the notification to through the webscoket
        Endpoint.broadcast!("user:#{recipient.id}", "new_notification", %{notification: notification})
      end) # end of task

      # retun the result
      {:ok, hire}

    else # the user is suspended
      {:error, :use_suspended, recipient.full_name}
    end # end of checking if the user is suspended

  rescue
    # the user does not exist
    Ecto.NoResultsError ->
      # return an error
      {:error, :user_not_found}
  end # end of create new hire request

  @doc """
    Accepts a direct hire request
  """
  def accept_direct_hire_request(%User{} = user, hire_id) do
    # preload the workprofile and diret hires
    user = Repo.preload(user, [work_profile: [direct_hires: from(hire in DirectHire, where: hire.id == ^hire_id)]])
    # get the hire
    [hire | _rest] = user.work_profile.direct_hires
    # accept the direct hires
    with hire <- hire |> Ecto.Changeset.change(%{is_accepted: true, is_pending: false}) |> Repo.update!() do
      # send a notification to the owner of the hire about the accepting of the hire
      Task.start(fn ->
        # preload the owner of the hire
        owner = Repo.preload(hire, [:user]).user
        # message
        message = "#{user.full_name} has accepted to be contracted to work on your direct hire request. Review the request and assign the order."
        # send email notification to the user
        NewEmail.new_email_notification(owner, "Direct Hire Acceptance", "#{message} \n Login to your account to assign the order.")
        # send the email
        |> Mailer.deliver_later()

        # create a notificaiton
        {:ok, notification} = Notifications.create_notification(%{
          user_id: owner.id,
          asset_type: "Direct Hire Request",
          asset_id: hire.id,
          notification_type: "Direct Hire Request Acceptance",
          message: message
        })
        # send the notification
        Endpoint.broadcast!("user:#{owner.id}", "new_notification", %{notificaiton: notification})
      end) # end of task

      # return the hire
      {:ok, hire}
    end # end of with
  end # end of accepting a direct hire request

  @doc """
    Rejects a direct hire request
  """
  def reject_direct_hire_request(%User{} = user, hire_id) do
    # get the hire
    [hire | _rest] = Repo.preload(user, [work_profile: [direct_hires: from(hire in DirectHire, where: hire.id == ^hire_id)]]).work_profile.direct_hires
    # reject the direct hires
    with hire <- hire |> Ecto.Changeset.change(%{is_accepted: false, is_rejected: true, is_pending: false}) |> Repo.update!() do
      # send a notification to the owner of the hire about the accepting of the hire
      Task.start(fn ->
        # preload the owner of the hire
        owner = Repo.preload(hire, [:user]).user
        # message
        message = "#{user.full_name} has declient to be contracted to work on your direct hire request. Please revie the request to reassign or make it public."
        # send email notification to the user
        NewEmail.new_email_notification(owner, "Direct Hire Rejection", "#{message} \n Login to your account to re-assign the order.")
        # send the email
        |> Mailer.deliver_later()

        # create a notificaiton
        {:ok, notification} = Notifications.create_notification(%{
          user_id: owner.id,
          asset_type: "Direct Hire Request",
          asset_id: hire_id,
          notification_type: "Direct Hire Request Rejction.",
          message: message
        })
        # send the notification
        Endpoint.broadcast!("user:#{owner.id}", "new_notification", %{notificaiton: notification})
      end) # end of task

      # return the hire
      {:ok, hire}
    end # end of with
  end # end of rejecting direct hire request

  # function for assigning the order made for the hire
  def assign_order_from_direct_hire(%User{} = user, hire_id) do
    # get the contractor to whom the direct hire was inteded to
    [hire | _rest] = Repo.preload(user, [direct_hires: from(hire in DirectHire, where: hire.id == ^hire_id)]).direct_hires
    # get the work profilt for the hire
    hire = Repo.preload(hire, [:work_profile])
    # get the order for the hire
    order = Orders.get_order!(hire.order_id)

    # assign the order
    Eworks.Orders.API.assign_order(user, order, hire.work_profile.user_id)
  end # end of assign_order_from_direct_hire

  @doc """
    Cancels a direct hire request
  """
  def cancel_direct_hire_request(%User{} = user, hire_id) do
    # get the direct hire
    hire = Requests.get_direct_hire!(hire_id)
    # cancel the direct hire
    with hire <- hire |> Ecto.Changeset.change(%{is_cancelled: true, is_pending: false}) |> Repo.update!() do
      # notify the person being assigned the job
      Task.start(fn ->
        # get the person for whom the hire was intended for
        profile = Accounts.get_work_profile!(hire.work_profile_id) |> Repo.preload(:user)
        # create a new notification for the person for whom the request was intended
        {:ok, notification} = Notifications.create_notification(%{
          user_id: profile.user.id,
          asset_id: hire.id,
          asset_type: "Direct Hire Request",
          notification_type: "Direct Hire Request Cancellation",
          message: "#{user.full_name} has cancelled their direct hire request for you to work on their order."
        })
        # send the notification in real time
        Endpoint.broadcast!("user:#{profile.user.id}", "new_notification", %{notificaiton: notification})
      end)

    # return the result
    :ok
    end # end of with
  end # end of canceldirect hire request

end # end of Eworks.Request.API
