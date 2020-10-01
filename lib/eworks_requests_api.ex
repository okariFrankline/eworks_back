defmodule Eworks.Requests.API do
  @moduledoc """
    Defines api functions for handling business logic for requests
  """
  import Ecto.Query, warn: false
  alias Eworks.{Repo, Notifications, Accounts}
  alias Eworks.Accounts.{User}
  alias Eworks.Requests.{DirectHire}
  alias Eworks.API.Utils
  alias Eworks.Utils.{NewEmail, Mailer}
  alias EworksWeb.Endpoint

  @doc """
    Returns a list of direct hires for a user
  """
  def list_direct_hires(type, %User{} = user) do
    # check the type
    case type do
      :client ->
        # get the direct hires made by this user and for each of the hires, preload the order and the person assigned the order
        direct_hires = Repo.preload(user, [direct_hires: [:order, work_profile: [:user]]]).direct_hires
        # returnt the direct hires
        {:ok, direct_hires}

      :contractor ->
        # get the direct hires made to this user
        hires = Repo.preload(user, [work_profiles: [direct_hires: from(hire in DirectHire, where: hire.is_pending == false)]]).direct_hires
        # for each of the hires. preload their orders
        hires = Stream.map(hires, fn hire -> hire |> Repo.preload([:order]) end) |> Enum.to_list()
        # return the hires
        {:ok, hires}
    end # end of case for the type
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
        message = "#{user.full_name} has made a direct hire request to you to work on his/her order."
        # create a new email
        NewEmail.new_email_notification(recipient, "New Direct Hire Request", "#{message} \n Please Login to view details.")
        # send the email
        |> Mailer.deliver_later()

        # create a new notification
        {:ok, notification} = Notifications.create_notification(%{
          user_id: recipient.id,
          asset_type: :direct_hire,
          asset_id: hire.id,
          message: message
        })
        # send the notification to through the webscoket
        Endpoint.broadcast!("user:#{recipient.id}", "notification::direct_hire_request", %{notification: Utils.render_notification(notification)})
      end) # end of task

      # preload the order and return the result
      hire = Repo.preload(hire, [:order])
      # retun the result
      {:ok, %{hire: hire, recipient: recipient}}
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
    # get the hire with the given id
    [hire | _rest] = Repo.preload(user, [work_profile: [direct_hires: from(hire in DirectHire, where: hire.id == ^hire_id)]]).work_profile.direct_hires
    # accept the direct hires
    with hire <- hire |> Ecto.Changeset.change(%{is_accepted: true, is_pending: false}) |> Repo.update!() do
      # send a notification to the owner of the hire about the accepting of the hire
      Task.start(fn ->
        # preload the owner of the hire
        owner = Repo.preload(hire, [:user]).user
        # message
        message = "#{user.full_name} has accepted your direct hire request to work on your order."
        # send email notification to the user
        NewEmail.new_email_notification(owner, "Direct Hire Acceptance", "#{message} \n Login to your account to assign the order.")
        # send the email
        |> Mailer.deliver_later()

        # create a notificaiton
        {:ok, notification} = Notifications.create_notification(%{
          user_id: owner.id,
          asset_type: :direct_hire,
          asset_id: hire_id,
          mesage: "#{message}. Continuer to assign the order to the contractor."
        })
        # send the notification
        Endpoint.broadcast!("user:#{owner.id}", "notification::direct_hire_acceptance", %{notificaiton: Utils.render_notification(notification)})
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
        message = "#{user.full_name} has rejected your direct hire request to work on your order."
        # send email notification to the user
        NewEmail.new_email_notification(owner, "Direct Hire Rejection", "#{message} \n Login to your account to re-assign the order.")
        # send the email
        |> Mailer.deliver_later()

        # create a notificaiton
        {:ok, notification} = Notifications.create_notification(%{
          user_id: owner.id,
          asset_type: :direct_hire,
          asset_id: hire_id,
          mesage: "#{message}. Continue to re-assign the order to the contractor."
        })
        # send the notification
        Endpoint.broadcast!("user:#{owner.id}", "notification::direct_hire_rejection", %{notificaiton: Utils.render_notification(notification)})
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
    hire = Repo.preload(hire, [:work_profile, :order])

    # assign the order
    Eworks.Orders.API.assign_order(user, hire.order, hire.work_profile.user_id)
  end # end of assign_order_from_direct_hire


end # end of Eworks.Request.API
