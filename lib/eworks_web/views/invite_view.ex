defmodule EworksWeb.Invites.InviteView do
  use EworksWeb, :view

  alias EworksWeb.OrderListView

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
        is_draft: invite.is_draft,
        category: invite.category,
        deadline: show_deadline(invite.deadline),
        required_collaborators: invite.required_collaborators,
        order_id: invite.order_id,
        specialty: invite.specialty,
        description: invite.description,
        show_more: invite.show_more,
        owner_name: invite.owner_name,
        posted_on: NaiveDateTime.to_iso8601(invite.inserted_at)
      }
    }
  end # end of invite.json

  @doc """
    Renders my_invites.json
  """
  def render("my_invites.json", %{invites: invites, next_cursor: cursor}) do
    %{
      data: %{
        invites: render_many(invites, __MODULE__, "my_invite.json"),
        next_cursor: cursor
      }
    }
  end # end of my_invites.json

  @doc """
    Renders my_invite.json
  """
  def render("my_invite.json", %{invite: invite}) do
    %{
      id: invite.id,
      payable_amount: invite.payable_amount,
      payment_schedule: invite.payment_schedule,
      is_paid_for: invite.is_paid_for,
      is_cancelled: invite.is_cancelled,
      is_assigned: invite.is_assigned,
      is_draft: invite.is_draft,
      category: invite.category,
      deadline: show_deadline(invite.deadline),
      required_collaborators: invite.required_collaborators,
      order_id: invite.order_id,
      specialty: invite.specialty,
      description: invite.description,
      show_more: invite.show_more,
      owner_name: invite.owner_name,
      posted_on: NaiveDateTime.to_iso8601(invite.inserted_at),
      active_offers: Enum.count(invite.collaboration_offers)
    }
  end

  @doc """
    Renders display_invite.json
  """
  def render("display_invites.json", %{invites: invites, next_cursor: cursor, offer_invite_ids: ids}) do
    %{
      data: %{
        invites: render_many(invites, __MODULE__, "display_invite.json"),
        next_cursor: cursor,
        invite_ids: List.flatten(ids)
      }
    }
  end # end of display invites

  @doc """
    Renders my_offers.json
  """
  def render("my_offers.json", %{offers: offers}) do
    %{
      data: %{
        offers: render_many(offers, __MODULE__, "my_offer.json")
      }
    }
  end # end of my_offers.json

  @doc """
    renders display_invite.json
  """
  def render("display_invite.json", %{invite: invite}) do
    %{
      id: invite.id,
      payable_amount: invite.payable_amount,
      payment_schedule: invite.payment_schedule,
      is_paid_for: invite.is_paid_for,
      is_cancelled: invite.is_cancelled,
      is_assigned: invite.is_assigned,
      is_draft: invite.is_draft,
      category: invite.category,
      deadline: show_deadline(invite.deadline),
      required_collaborators: invite.required_collaborators,
      order_id: invite.order_id,
      specialty: invite.specialty,
      description: invite.description,
      show_more: invite.show_more,
      owner_name: invite.owner_name,
      posted_on: NaiveDateTime.to_iso8601(invite.inserted_at)
    }
  end

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
    Renders my_offer.json
  """
  def render("my_offer.json", %{invite: offer}) do
    %{
      id: offer.id,
      is_cancelled: offer.is_cancelled,
      is_rejected: offer.is_rejected,
      is_pending: offer.is_pending,
      is_accepted: offer.is_accepted,
      placed_on: NaiveDateTime.to_iso8601(offer.inserted_at),
      has_accepted_invite: offer.has_accepted_invite,
      asking_amount: offer.asking_amount,
      invite: render_one(offer.invite, __MODULE__, "display_invite.json")
    }
  end # end of my_offer.json

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
      asking_amount: offer.asking_amount,
      show_more: offer.show_more,
      is_accepted: offer.is_accepted,
      owner: %{
        full_name: offer.owner_name,
        rating: offer.owner_rating,
        job_success: offer.owner_job_success,
        about: offer.owner_about,
        id: offer.user_id,
        profile_pic: offer.owner_profile_pic,
        skills: offer.owner_skills
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
  # rednr the deadline
  defp show_deadline(date) when is_nil(date), do: nil
  defp show_deadline(date), do: Date.to_iso8601(date)

end
