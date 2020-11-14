defmodule EworksWeb.Users.UserView do
  use EworksWeb, :view

  alias Eworks.Uploaders.ProfilePicture
  alias Eworks.API.Utils
  alias EworksWeb.OrderListView

  @doc """
    Renders of new_user.json
  """
  def render("new_user.json", %{user: user}) do
    # retrun the result
    %{
      data: %{
        # user with only the full name, is active and the username
        user: %{
          id: user.id,
          full_name: user.full_name,
          is_active: user.is_active,
          username: user.username,
          auth_email: user.auth_email
        },
        message: "Thank you, #{user.full_name}, for creating an account. Your activation key has been sent to #{user.auth_email}"
      }
    }
  end # end of the new_user.json

  @doc """
     Rednders contractor_profile.json
  """
  def render("contractor_profile.json", %{user: user, previous_hires: hires}) do
    %{
      data: %{
        user: %{
          id: user.id,
          is_active: user.is_active,
          country: user.country,
          city: user.city,
          location: "#{String.capitalize(user.city)}, #{String.capitalize(user.country)}",
          is_suspended: user.is_suspended,
          profile_complete: user.profile_complete,
          user_type: user.user_type,
          is_company: user.is_company,
          full_name: user.full_name,
          profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}, :thumb)),
          auth_email: user.auth_email,
          phone: user.phone,
          # work profile
          work_profile: %{
            skills: user.work_profile.skills,
            about: user.work_profile.professional_intro,
            job_success: user.work_profile.success_rate,
            job_hires: user.work_profile.job_hires,
            rating: user.work_profile.rating,
            show_more: user.work_profile.show_more
          },
        },
        # previous hires
        previous_hires: render_many(hires, __MODULE__, "order.json")
      }
    }
  end # end of render contrator profile .json

  @doc """
  Renders client profile.json
  """
  def render("client_profile.json", %{user: user}) do
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json")
      }
    }
  end # end of client profile.json

  @doc """
   Renders the saved-workers
  """
  def render("saved_workers.json", %{users: users}) do
    IO.inspect(users)
    %{
      data: %{
        workers: render_many(users, __MODULE__, "saved_worker.json")
      }
    }
  end # end of saved workers

  @doc """
    Renders saved worker
  """
  def render("saved_worker.json", %{user: user}) do
    %{
      id: user.id,
      profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}, :thumb)),
      about: user.work_profile.professional_intro,
      show_more: user.work_profile.show_more,
      job_success: user.work_profile.success_rate,
      skills: user.work_profile.skills,
      full_name: user.full_name,
      rating: user.work_profile.rating
    }
  end # end of saved_worker.json



  # @doc """
  #   Renders the profile.json
  # """
  # def render("profile.json", %{user: user} = result) do
  #   if user.user_type == "Client" do
  #     %{
  #       data: %{
  #         user: render_one(user, __MODULE__, "user.json")
  #       }
  #     }
  #   else
  #     # the user is a practise
  #     render("practise_profile.json", result)
  #   end
  # end # end of profile.json

  # @doc """
  #   Renders the practise_profile.json
  # """
  # def render("practise_profile.json", %{user: user}) do
  #   %{
  #     data: %{
  #       user: render_one(user, __MODULE__, "user.json"),
  #       work_profile: %{
  #         id: user.work_profile.id
  #       }
  #     }
  #   }
  # end # end of practise_profile.json

  @doc """
    Render of logged_in.json
  """
  def render("logged_in.json", %{user: user}) do
    # return the data
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json")
      }
    }
  end # end of logged_in.json

  @doc """
    Renders the work_profile.json
  """
  def render("work_profile.json", %{work_profile: profile, user: user}) do
    %{
      data: %{
        # previous hires
        previous_hires: render_previous_hires(profile.previous_hires),
        # profile owner
        user: %{
          id: user.id,
          name: user.full_name,
          is_active: user.is_active,
          username: user.username,
          country: user.country,
          city: user.city,
          profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}, :thumb))
        },
        # profile information
        id: profile.id,
        skills: profile.skills,
        professional_intro: profile.professional_intro,
        cover_letter: profile.professional_intro,
        success_rate: profile.success_rate,
        job_hires: profile.job_hires,
        rating: profile.rating
      }
    }
  end # end of work_profile.json

  @doc """
    offers.json
  """
  def render("offers.json", %{offers: offers, next_cursor: next_cursor}) do
    %{
      data: %{
        offers: render_many(offers, __MODULE__, "offer.json"),
        next_cursor: next_cursor
      }
    }
  end

  @doc """
    offer.json
  """
  def render("offer.json", %{user: offer}) do
    %{
      id: offer.id,
      submitted_on: NaiveDateTime.to_iso8601(offer.inserted_at),
      asking_amount: offer.asking_amount,
      is_accepted: offer.is_accepted,
      is_rejected: offer.is_rejected,
      is_cancelled: offer.is_cancelled,
      is_pending: offer.is_pending,
      has_accepted_order: offer.has_accepted_order,
      order_accepting_pending: offer.order_accepting_pending,
      order: render_one(offer.order, OrderListView, "order.json")
    }
  end

  # user.json
  def render("user.json", %{user: user}) do
    # return the user's firstname, last name and is active
    %{
      id: user.id,
      full_name: user.full_name,
      is_active: user.is_active,
      username: user.username,
      auth_email: user.auth_email,
      country: user.country,
      city: user.city,
      is_suspended: user.is_suspended,
      profile_complte: user.profile_complete,
      user_type: user.user_type,
      is_company: user.is_company,
      profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}, :thumb)),
      phone: user.phone,
      saved_workers: user.saved_workers
    }
  end

  @doc """
    Renders the upgraded_profile.json
  """
  def render("upgraded_work_profile.json", %{work_profile: profile}) do
    %{
      data: %{
        # render the work rofile
        work_profile: %{
          id: profile.id,
          is_upgraded: profile.is_upgraded,
          last_upgraded_on: profile.last_upgraded_on,
          upgrade_expiry_date: profile.upgrade_expiry_date,
          is_upgrade_expired: profile.is_upgrade_expired,
          skills: profile.skills,
          professional_intro: profile.professional_intro,
          cover_letter: profile.professional_intro,
          success_rate: profile.succes_rate,
          job_hires: profile.job_hires,
          rating: profile.rating
        }
      }
    }
  end # end of upgraded_profile.json

  # order.json
  def render("order.json", %{previous_hire: order}) do
    %{
      specialty: order.specialty,
      description: order.description,
      rating: order.rating,
      comment: order.comment,
      owner: order.owner
    }
  end

  # success.json
  def render("success.json", %{message: message}) do
    %{
      data: %{
        success: true,
        details: message
      }
    }
  end

  # render the orders
  defp render_previous_hires(previous_hires) when is_list(previous_hires), do: render_many(previous_hires, __MODULE__, "order.json")
  defp render_previous_hires(_), do: nil
end # end of the module
