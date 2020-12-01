defmodule Eworks.Repo.Migrations.CreateUserSession do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :text, null: true

      add :user_id, references(:users, type: :binary_id, on_delete: :nothing)

      timestamps()
    end # end of create table function

    # indes for the token
    create unique_index(:sessions, [:token])
    # create index on the user id
    create index(:sessions, [:user_id])
  end # end of change function
end
