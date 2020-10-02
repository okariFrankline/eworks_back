defmodule EworksWeb.WorkersController do
  use EworksWeb, :controller

  import Ecto.Query, warn: false
  alias Eworks.{Repo}
  alias Eworks.Accounts.User

  @doc """
    Inserts the current user as the third arguement to all the actions
  """
  def action(conn, _) do
    # args
    args = [conn, conn.params, conn.assigns.current_user]
    # apply action
    apply(__MODULE__, action_name(conn), args)
  end # end of action

  @doc """
    Lists current workers
  """
  def list_workers(conn, %{"metadata" => metadata}, _user) do
    # query for getting the workers
    query = from(
      user in User,
      # ensure the user is active, not suspended and is an independent contractor
      where: user.user_type == "Independent Contractor" and user.is_suspended == true and user.is_active == true,
      # get the work profile as well
      join: work_profile in assoc(user, :work_profile),
      # order by the inserted at and id
      order_by: [asc: user.inserted_at, asc: user.id],
      # preload the work profile
      preload: [work_profile: work_profile]
    )

    # get the page based on whether the metadata is available or not
    page = if metadata do
      # get the cursor_after
      cursor_after = metadata.after
      # load the results
      Repo.paginate(query, after: cursor_after, cursor_fields: [:inserted_at, :id], limit: 10)

    else
      # get the first 10 users
      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 10)
    end # end of metadata
    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("workers.json", workers: page.entries, metadata: page.metadata)
  end # end of list_workers

  @doc """
    searches for workers based on the skills
  """
  def search_based_on_skills(conn,  %{"skill" => skill, "metadata" => metadata}, _user) do
    # query for getting the results
    query = from(
      user in User,
      # ensure the user is active, not suspended and is an independent contractor
      where: user.user_type == "Independent Contractor" and user.is_suspended == true and user.is_active == true,
      # get the work profile as well
      join: work_profile in assoc(user, :work_profile),
      # ensure the skill is in the skills
      where: ^skill in work_profile.skills,
      # order by the inserted at and id
      order_by: [asc: user.inserted_at, asc: user.id],
      # preload the work profile
      preload: [work_profile: work_profile],
      # select the user
      select: user
    )

    # get the page based on whether the metabase is given
    page = if metadata do
      # get the cursor_after
      cursor_after = metadata.after
      # load the results
      Repo.paginate(query, after: cursor_after, cursor_fields: [:inserted_at, :id], limit: 10)
    else
      # get the first 10 users
      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 10)
    end # end of metadata

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("workers.json", workers: page.entries, metadata: page.metadata)
  end # end of the search by skill

  @doc """
    gets worker profile
  """
  def get_worker(conn, %{"user_id" => id}, _user) do
    # query for getting a user
    query = from(
      user in User,
      # ensure the id is a match
      where: user.id == ^id,
      # add the work profile
      join: work_profile in assoc(user, :work_profile),
      # load the previous hires
      join: previous_hire in assoc(work_profile, :previous_hires),
      # prelod the work profile and the previous hires
      preload: [work_profile: {work_profile, previous_hires: previous_hire}]
    )

    # get the result
    case Repo.one(query) do
      # the user not found
      nil ->
        # return the result
        conn
        # put the status
        |> put_status(:not_found)
        # put the view
        |> put_view(EworksWeb.ErrorView)
        # return the result
        |> render("worker_not_found.json")

      # user found
      %User{} = user ->
        conn
        # put the status
        |> put_status(:ok)
        # render the worker
        |> render("worker.json", user: user)
    end # end of case for getting worker
  end # end of get worker

  @doc """
    Saves a given worker
  """
  def save_worker(conn, %{"user_id" => id}, user) do
    # add the user's id to the list of saved worked
    case Ecto.Changeset.change(user, %{saved_workers: [id | user.saved_workers]}) |> Repo.update() do
      # success saving
      {:ok, _user} ->
        conn
        # put the status
        |> put_status(:ok)
        # render success
        |> render("success.json")

      {:error, _} ->
        conn
        # put the status
        |> put_status(:bad_request)
        # put view
        |> put_view(EworksWeb.ErrorView)
        # render the failed
        |> render("saved_failed.json")
    end # end of case
  end # end of save worker

  @doc """
    Gets the list of all the saved contractors
  """
  def list_saved_workers(conn, _params, user) do
    workers = Stream.map(user.saved_workers, fn worker_id ->
      # query for the worker
      from(
        user in User,
        # ensure id match
        where: user.id == ^worker_id,
        # join the work profile
        join: work_profile in assoc(user, :work_profile),
        # preload the work profile
        preload: [work_profile: work_profile]
      )
      # get the user
      |> Repo.one!()
    end) |> Enum.to_list()

    # retun the result
    conn
    # put the status
    |> put_status(:ok)
    # render the workers
    |> render("workers.json", workers: workers)
  end # end of getting the saved workers


end # end of module
