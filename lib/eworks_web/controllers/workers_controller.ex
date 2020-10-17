defmodule EworksWeb.WorkersController do
  use EworksWeb, :controller

  import Ecto.Query, warn: false
  alias Eworks.{Repo}
  alias Eworks.Accounts.User
  alias Eworks.Dataloader.Loader

  action_fallback EworksWeb.FallbackController

  @doc """
    Inserts the current user as the third arguement to all the actions
  """
  def action(conn, _) do
    # args
    args = [conn, conn.params, conn.assigns.current_user]
    # apply action
    apply(__MODULE__, action_name(conn), args)
  end # end of action

  defp load_previous_hires(previous_hires_ids) do
    # check to ensure the ids are not emlty
    if not Enum.empty?(previous_hires_ids) do
      # get the dataloader
      Loader.get_data_loader()
      # load the order orders with the ids
      |> Dataloader.load_many(Orders, Order, previous_hires_ids)
      # run the loader
      |> Dataloader.run()
      # get the results
      |> Dataloader.get_many(Orders, Order, previous_hires_ids)
    else
      # return an empty list
      []
    end # end of previous hires ids
  end

  @doc """
    Returns the profile of a given user
  """
  def get_worker_profile(conn, %{"user_id" => id}, _user) do
    # query for returning the user and his/her work profile
    user = from(
      user in User,
      # ensure the ids match
      where: user.id == ^id,
      # join work profile
      join: profile in assoc(user, :work_profile),
      # preload the work profile
      preload: [work_profile: profile]
    )
    # get the user
    |> Repo.one!()

    # get the previous hires
    previous_hires = load_previous_hires(user.work_profile.previous_hires)

    # return the results
    conn
    # put the status to ok
    |> put_status(:ok)
    # render the results
    |> render("worker_profile.json", user: user, previous_hires: previous_hires)

  rescue
    # the user with result does not exist
    Ecto.NoResultsError ->
      # return the results
      conn
      # put the status
      |> put_status(:not_found)
      # put the view
      |> put_view(EworksWeb.ErrorView)
      # render prof not nounf
      |> render("prof_not_found")
  end # end of worker profile

  @doc """
    Lists current workers
  """
  def list_workers(conn, %{"metadata" => after_cursor}, _user) do
    # query for getting the workers
    query = from(
      user in User,
      # ensure the user is active, not suspended and is an independent contractor
      where: user.user_type == "Independent Contractor" and user.is_suspended == false and user.is_active == true,
      # get the work profile as well
      join: work_profile in assoc(user, :work_profile),
      # order by the inserted at and id
      order_by: [asc: user.inserted_at, asc: user.id],
      # preload the work profile
      preload: [work_profile: work_profile]
    )

    # get the page based on whether the metadata is available or not
    page = if after_cursor != "false" do
      # get the cursor_after
      cursor_after = after_cursor
      # load the results
      Repo.paginate(query, after: cursor_after, cursor_fields: [:inserted_at, :id], limit: 5)

    else
      # get the first 10 users
      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 5)
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
  def search_based_on_skills(conn,  %{"skill" => skill, "metadata" => after_cursor}, _user) do
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
    page = if after_cursor do
      # get the cursor_after
      cursor_after = after_cursor
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
    Saves a given worker
  """
  def save_worker(conn, %{"contractor_id" => id}, user) do
    # add the user's id to the list of saved worked
    case Ecto.Changeset.change(user, %{saved_workers: [id | user.saved_workers]}) |> Repo.update() do
      # success saving
      {:ok, _user} ->
        conn
        # put the status
        |> put_status(:ok)
        # render success
        |> render("success.json", message: "Independent contractor successfully added to your saved list.")

      {:error, _} ->
        conn
        # put the status
        |> put_status(:bad_request)
        # put view
        |> put_view(EworksWeb.ErrorView)
        # render the failed
        |> render("failed.json", message: "Failed. Contractor could not be saved. Please try again later.")
    end # end of case
  end # end of save worker

  @doc """
    Unsaves a worker
  """
  def unsave_worker(conn, %{"contractor_id" => id}, user) do
    # remove the given id from the list of saved workers
    saved_workers = List.delete(user.saved_workers, id)
    # update the iser to save the new list
    case Ecto.Changeset.change(user, %{saved_workers: saved_workers}) |> Repo.update() do
      # saving was successful
      {:ok, _user} ->
        # return the result
        conn
        # put the status
        |> put_status(:ok)
        # return success
        |> render("success.json", message: "Independent contractor successfully removed from your saved list.")

      # saving was unsuccessful
      {:error, _changeset} ->
        # return the result
        conn
        # put the status
        |> put_status(400)
        # put the error view
        |> put_view(EworksWeb.ErrorView)
        # render result
        |> render("failed.json", message: "Failed. Independent Contractor could not be removed. Please try again later.")
    end
  end # end of unsave contractors

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
    end)
    |> Enum.to_list()

    # retun the result
    conn
    # put the status
    |> put_status(:ok)
    # render the workers
    |> render("workers.json", workers: workers)
  end # end of getting the saved workers


end # end of module
