defmodule Eworks.Release.EctoTasks do
  @moduledoc """
    Provides ecto taks for running the app once the release has being create
    Commands are run using:
      _build/prod/rel/eworks/bin/eworks evel "Eworks.Release.EctoTasks.migrate"
  """
  @app :eworks

  @doc """
     Peforms the migration for the eworks
  """
  def migrate do
    # load the app
    load_app()
    # start the ssl app
    # perform migrations for all the apps
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc """
    function for resetting the db
  """
  def reset_db do
    load_app()
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, all: true))
    end
  end

  @doc """
     Performs rolling back of the migration
  """
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  # returns all the repos for the given app
  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  # loads the app
  defp load_app do
    # loads the app without starting the apps
    Application.load(@app)
  end

end # end of the module
