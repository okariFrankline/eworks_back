defmodule EworksWeb.Invites.InviteView do
  use EworksWeb, :view

  @doc """
    New invite json
  """
  def render("invite.json", %{invite: invite}) do
    %{
      data: %{
        id: invite.id,
        payable_amount: invite.payable_amount,
        payment_schedule: invite.payment_schedule,
        is_paid_for: invite.is_paid_for,
        is_cancelled: invite.is_cancelled,
        is_assigned: invite.is_assigned,
        category: invite.category,
        deadline: show_deadline(invite.deadline),
        required_collaborators: invite.required_collaborators,
        order_id: invite.order_id,
        specialty: invite.specialty,
        description: invite.description,
        show_more: invite.show_more
      }
    }
  end # end of invite.json

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
  end # end of offers.json

  @doc """
    Render the collaborators
  """
  def render("collaborator.json", %{invite: offer}) do
    %{
      full_name: offer.owner_name,
      rating: offer.owner_rating,
      job_success: offer.owner_job_success,
      about: offer.owner_about,
      id: offer.user_id,
      profile_pic: offer.owner_profile_pic
    }
  end # end of collaborator

  @doc """
    Render the offer
  """
  def render("offer.json", %{invite: offer}) do
    %{
      id: offer.id,
      is_cancelled: offer.is_cancelled,
      is_rejected: offer.is_rejected,
      is_pending: offer.is_pending,
      placed_on: NaiveDateTime.to_iso8601(offer.inserted_at),
      has_accepted_invite: offer.has_accepted_invite,
      show_more: offer.show_more,
      owner: %{
        full_name: offer.owner_name,
        rating: offer.owner_rating,
        job_success: offer.owner_job_success,
        about: offer.owner_about,
        id: offer.user_id,
        profile_pic: offer.owner_profile_pic,
      }
    }
  end # end of offer.json

  @doc """
    Renders invite_offer.josn
  """
  def render("invite_offer.json", %{offer: offer}) do
    %{
      data: %{
        offer: render_one(offer, __MODULE__, "offer.json")
      }
    }
  end # end of invite_offer.json

  @doc """
    Renders success
  """
  def render("success.json", %{message: message}) do
    %{
      data: %{
        success: true,
        details: message
      }
    }
  end # end of succes.json

  ################################# PRIVATE FUNCTIONS ####################
  # render the collaborators
  defp render_collaborators(offers, collaborators) do
    # filter the offers to ownly those whose owner's ids are in the list of assignees of the order
    collaborator_offers = Enum.filter(offers, fn offer -> offer.user_id in collaborators end)
    # call the render many for assigneess
    render_many(collaborator_offers, __MODULE__, "collaborator.json")
  end

  # redner invite offers
  defp render_invite_offers(offers, collaborators) do
    # filter only those offers whose owner's are not in the list of assignees of the order
    offers = Enum.filter(offers, fn offer ->
      # return only the offers whose oofer.user.order_id does not equal the current order id
      offer.user_id not in collaborators
    end)
    # render the offers
    render_many(offers, __MODULE__, "offer.json")
  end # end of render invite offers

  # rednr the deadline
  defp show_deadline(date) when is_nil(date), do: nil
  defp show_deadline(date), do: Date.to_iso8601(date)

end
