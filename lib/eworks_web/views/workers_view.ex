defmodule EworksWeb.WorkersView do
  use EworksWeb, :view
  alias Eworks.API.Utils
  alias Eworks.Uploaders.ProfilePicture

  @doc """
    Renders the worker_profile.json
  """
  def render("worker_profile.json", %{user: user, previous_hires: hires}) do
    %{
      data: %{
        id: user.id,
        full_name: user.full_name,
        profile_pic: Utils.upload_url(ProfilePicture.url({user.profile_pic, user}, :thumb)),
        work_profile: render_one(user.work_profile, __MODULE__, "work_profile.json"),
        previous_hires: render_many(hires, __MODULE__, "previous_hire.json")
      }
    }
  end # end of worker_profile.json

  @doc """
    Renders workers.json
  """
  def render("workers.json", %{workers: workers, metadata: metadata}) do
    %{
      data: %{
        workers: render_many(workers, __MODULE__, "worker.json"),
        cursor_after: metadata.after
      }
    }
  end # end of metadata

  @doc """
    Renders the success.json
  """
  def render("success.json", %{message: message}) do
    %{
      data: %{
        success: true,
        details: message
      }
    }
  end # end of success.json

  @doc """
    Renders the save_failed.json
  """
  def render("save_failed.json", _) do
    %{
      data: %{
        success: false,
        details: "Failed. Independent Contractor failed to saved."
      }
    }
  end # end of success.json

  @doc """
    Renders the worker.json
  """
  def render("worker.json", %{workers: worker}) do
    %{
      id: worker.id,
      full_name: worker.full_name,
      profile_pic: Utils.upload_url(ProfilePicture.url({worker.profile_pic, worker}, :thumb)),
      job_success: worker.work_profile.success_rate,
      rating: worker.work_profile.rating,
      about: worker.work_profile.professional_intro,
      job_hires: Enum.count(worker.work_profile.previous_hires),
      skills: worker.work_profile.skills,
      show_more: worker.work_profile.show_more
    }
  end # end of worker.json

  @doc """
    Renders the work profile
  """
  def render("work_profile.json", %{workers: profile}) do
    %{
      id: profile.id,
      job_success: profile.success_rate,
      rating: profile.rating,
      about: profile.professional_intro,
      skills: profile.skills,
      show_more: profile.show_more,
      job_hires: Enum.count(profile.previous_hires)
    }
  end # end of work_profile.json

  @doc """
    Renders the previous orders
  """
  def render("previous_hire.json", %{workers: hire}) do
    %{
      id: hire.id,
      description: hire.description,
      rating: hire.rating,
      comment: hire.comment,
      specialty: hire.specialty,
      owner_name: hire.owner_name,
      show_more: hire.show_more,
      posted_on: NaiveDateTime.to_iso8601(hire.inserted_at),
      rating: hire.rating,
      category: hire.category
    }
  end # end of previous hire
end # end of defining workers view
