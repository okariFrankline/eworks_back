defmodule EworksWeb.OrderView do
  use EworksWeb, :view

  alias Eworks.API.Utils
  alias Eworks.Uploaders.{OrderAttachment, ProfilePicture}


  @doc """
    Renders new_order.json
  """
  def render("new_order.json", %{new_order: order}) do
    %{
      data: %{
        id: order.id,
        description: order.description,
        specialty: order.specialty,
        category: order.category,
        attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
        duration: order.duration,
        order_type: order.order_type,
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        is_verified: order.is_verified,
        deadline: show_deadline(order.deadline),
        required_contractors: order.required_contractors,
        posted_on: Date.to_iso8601(order.inserted_at)
      }
    }
  end

  @doc """
    Renders order.json
  """
  def render("order.json", %{order: order}) do
    %{
      data: %{
        # order information
        id: order.id,
        description: order.description,
        is_verified: order.is_verified,
        is_assigned: order.is_assigned,
        is_complete: order.is_complete,
        is_paid_for: order.is_paid_for,
        accepted_offers: order.accepted_offers,
        specialty: order.specialty,
        category: order.category,
        order_type: order.order_type,
        duration: order.duration,
        # payment info
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        deadline: Date.to_iso8601(order.deadline),
        posted_on: Date.to_iso8601(order.inserted_at),
        required_contractors: order.required_contractors,
        offers_made: Enum.count(order.order_offers),
        attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
        # assignees and offers
        assignees: render_assignees(order.assignees, order.order_offers),
        offers: render_offers(order.assignees, order.order_offers)
      }
    }
  end # end of order.json

  @doc """
    Renders offer.json
  """
  def render("offer.json", %{order: offer}) do
    %{
      id: offer.id,
      asking_amount: offer.asking_amount,
      is_accepted: offer.is_accepted,
      is_rejected: offer.is_rejected,
      is_cancelled: offer.is_cancelled,
      has_accepted_order: offer.has_accepted_order,
      # owner of the offer
      owner: %{
        id: offer.user.id,
        full_name: offer.user.full_name,
        rating: offer.user.work_profile.rating,
        cover_letter: offer.user.work_profile.cover_letter,
        profile_pic: Utils.upload_url(ProfilePicture.url({offer.user.profile_pic, offer.user}))
      }
    }
  end # end of offers.json

  @doc """
    Renders assignee.json
  """
  def render("assignee.json", %{order: offer}) do
    %{
      id: offer.user.id,
      full_name: offer.user.full_name,
      rating: offer.user.work_profile.rating,
      about: offer.user.work_profile.professional_intro,
      job_success: offer.user.work_profile.success_rate,
      asking_amount: offer.asking_amount,
      profile_pic: Utils.upload_url(ProfilePicture.url({offer.user.profile_pic, offer.user}))
    }
  end # end of assignee.json

  @doc """
    Renders accepted_offer.json
  """
  def render("accepted_offer.json", %{accepted_offer: offer, order: order, user: user}) do
    %{
      data: %{
        id: offer.id,
        asking_amount: offer.asking_amount,
        is_accepted: offer.is_accepted,
        is_rejected: offer.is_rejected,
        is_cancelled: offer.is_cancelled,
        has_accepted_order: offer.has_accepted_order,
        # owner of the offer
        owner: %{
          id: user.id,
          full_name: user.full_name,
          profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}))
        },
        # the order for the offer
        order: %{
          id: order.id,
          description: order.description,
          specialty: order.specialty
        }
      }
    }
  end # end of accepted_offer.json

  # succes render
  def render("success.json", %{message: message}) do
    %{
      data: %{
        success: true,
        message: message
      }
    }
  end

############################### PRIVATE FUNCTION ######################################################

  defp render_assignees(order_assignees, offers) do
    # filter the offers to ownly those whose owner's ids are in the list of assignees of the order
    offers_for_assigned_users = Enum.filter(offers, fn offer -> offer.user_id in order_assignees end)
    # call the render many for assigneess
    render_many(offers_for_assigned_users, __MODULE__, "assignee.json")
  end # end of rendering is assigned

  # function for rendering the offers
  defp render_offers(order_assignees, offers) do
    # filter only those offers whose owner's are not in the list of assignees of the order
    offers_for_unassigned_users = Enum.filter(offers, fn offer ->
      # return only the offers whose oofer.user.order_id does not equal the current order id
      offer.user_id not in order_assignees
    end)
    # render the offers
    render_many(offers_for_unassigned_users, __MODULE__, "offer.json")
  end # end of render_offers/2

  defp show_deadline(date) when is_nil(date), do: nil
  defp show_deadline(date), do: Date.to_iso8601(date)

end # end of the module
