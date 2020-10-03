defmodule Eworks.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :notification_type, :string
      add :message, :string
      add :is_viewed, :boolean, default: false, null: false
      add :asset_type, :string
      add :asset_id, :binary_id
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:is_viewed])
  end
end
