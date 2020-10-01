defmodule Eworks.Request.API do
  @moduledoc """
    Defines api functions for handling business logic for requests
  """
  import Ecto.Query, warn: false
  alias Eworks.{Requests, Repo}
  alias Eworks.Accounts.{User, WorkProfile}
  alias Eworks.Request.{DirectHires}
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
        direct_hires = user |> Repo.preload([direct_hires: [:order, work_profile: [:user]]]).direct_hires
        # returnt the direct hires
        {:ok, direct_hires}

      :contractor ->
        # get the direct hires made to this user
        hires = user |> Repo.preload([work_profiles: [direct_hires: from(hire in DirectHire, where: hire.is_rejected == false)]]).direct_hires
        # for each of the hires. preload their orders
        hires = Stream.map(hires, fn hire -> Repo.preload([:order])) end) |> Enum.to_list()
        # return the hires
        {:ok, hires}
    end # end of case for the type
  end # end of list direct hires

  @doc """
    creaetes a new direct hire request
  """
  def create_new_direct_hire_request(%User{} = user, order_id, recipeint_id) do
    # ensure that the recipient exist
    recipient = Accounts.get_user!(recipient_id) |> Repo.preload(:work_profile)
    # ensure the user is not suspended
    if not recipient.is_suspended do
      # create a new request
      with hire <- user |> Ecto.build_assoc(:direct_hires, %{work_profile_id: recipient.work_profile.id, order_id: order_id}) |> Repo.insert!() do
        # start a task to send the owner of the request a notification throught he email and websocket
        Task.start(fn ->
          # message
          message = "#{user.full_name} has made a direct hire request to you to work on his/her order."
          # create a new email
          NewEmail.new_email_notification(recipient, "New Direct Hire Request", "#{message} \n Please Login to view details.")
          # send the email
          |> Mailer.deliver_later()

          # create a new notification
          {:ok, notification} = Notification.create_notification(%{
            user_id: recipeint.id,
            asset_type: :direct_hire,
            asset_id: hire.id,
            message: message
          })
          # send the notification to through the webscoket
          Endpoint.broadcast!("user:#{recipient.id}", "notification::direct_hire_request", %{notification: Utils.render_notification(notification)})
        end) # end of task
      end # end of creating a new hire request

      # preload the order and return the result
      hire = Repo.preload(:order)
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

  end # end of accepting a direct hire request


end # end of Eworks.Request.API
