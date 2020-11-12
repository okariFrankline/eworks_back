defmodule EworksWeb.Orders.OrderView do
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
        posted_on: NaiveDateTime.to_iso8601(order.inserted_at)
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
        is_cancelled: order.is_cancelled,
        accepted_offers: order.accepted_offers,
        specialty: order.specialty,
        category: order.category,
        order_type: order.order_type,
        duration: order.duration,
        show_more: order.show_more,
        owner_name: order.owner_name,
        # payment info
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        deadline: show_deadline(order.deadline),
        posted_on: NaiveDateTime.to_iso8601(order.inserted_at),
        required_contractors: order.required_contractors,
        offers_made: Enum.count(order.order_offers),
        attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
      }
    }
  end # end of order.json

  @doc """
    Renders order.json
  """
  def render("my_order.json", %{order: order}) do
    %{
      data: %{
        # order information
        id: order.id,
        description: order.description,
        is_verified: order.is_verified,
        is_assigned: order.is_assigned,
        is_complete: order.is_complete,
        is_paid_for: order.is_paid_for,
        is_cancelled: order.is_cancelled,
        # accepted_offers: order.accepted_offers,
        specialty: order.specialty,
        category: order.category,
        order_type: order.order_type,
        duration: order.duration,
        show_more: order.show_more,
        owner_name: order.owner_name,
        # payment info
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        deadline: show_deadline(order.deadline),
        posted_on: NaiveDateTime.to_iso8601(order.inserted_at),
        required_contractors: order.required_contractors,
        attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
      }
    }
  end # end of order.json

  @doc """
    Renders offers.json
  """
  def render("offers.json", %{offers: offers, next_cursor: cursor}) do
    %{
      data: %{
        offers: render_many(offers, __MODULE__, "offer.json"),
        next_cursor: cursor
      }
    }
  end  # end of offers.json

  @doc """
    Renders assignees.json
  """
  def render("assignees.json", %{assignees: assignees}) do
    %{
      data: %{
        assignees: render_many(assignees, __MODULE__, "assignee.json")
      }
    }
  end

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
        cover_letter: offer.user.work_profile.professional_intro,
        profile_pic: Utils.upload_url(ProfilePicture.url({offer.user.profile_pic, offer.user})),
        show_more: offer.user.work_profile.show_more
      }
    }
  end # end of offers.json

  @doc """
    Renders assignee.json
  """
  def render("assignee.json", %{order: user}) do
    %{
      id: user.id,
      full_name: user.full_name,
      about: user.work_profile.professional_intro,
      rating: user.work_profile.rating,
      job_success: user.work_profile.success_rate,
      show_more: user.work_profile.show_more,
      profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}))
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

  defp show_deadline(date) when is_nil(date), do: nil
  defp show_deadline(date), do: Date.to_iso8601(date)

end # end of the module
