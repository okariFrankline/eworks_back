defmodule EworksWeb.UserView do
  use EworksWeb, :view

  # new user.json
  def render("new_user.json", %{user: user, token: token}) do
    # retrun the result
    %{
      data: %{
        # user with only the full name, is active and the username
        user: %{
          name: user.full_name,
          is_active: user.is_active,
          username: user.username,
        },
        token: token
      }
    }
  end # end of the new_user.json

  # profile.json
  def render("profile.json", %{user: user}) do
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json")
      }
    }
  end

  # logged_in.json
  def render("logged_in.json", %{user: user, token: token}) do
    # return the data
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json"),
        token: token
      }
    }
  end # end of logged_in.json

  # work_profile.json
  def render("work_profile", %{work_profile: profile}) do
    %{
      data: %{
        # previous hires
        previous_hires: render_many(profile.previous_hires, __MODULE__, "order.json"),
        # profile owner
        user: %{
          name: profile.user.full_name,
          is_active: profile.user.is_active,
          username: profile.user.username,
          country: profile.user.country,
          city: profile.user.city,
          profile_pic: profile.user.profile_pic
        },
        # profile information
        id: profile.id,
        skills: profile.skills,
        professional_intro: profile.professional_intro,
        cover_letter: profile.cover_letter,
        success_rate: profile.succes_rate,
        job_hires: profile.job_hires,
        rating: profile.rating
      }
    }
  end

  # user.json
  def render("user.json", %{user: user}) do
    # return the user's firstname, last name and is active
    %{
      name: user.full_name,
      is_active: user.is_active,
      username: user.username,
      country: user.country,
      city: user.city,
      is_company: user.is_company,
      user_type: user.user_type,
      profile_pic: user.profile_pic
    }
  end

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
end # end of the module
