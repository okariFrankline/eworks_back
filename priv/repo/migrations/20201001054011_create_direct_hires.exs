defmodule Eworks.Repo.Migrations.CreateDirectHires do
  use Ecto.Migration

  def change do
    create table(:direct_hires, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_accepted, :boolean, default: false, null: false
      add :is_assigned, :boolean, default: false, null: false
      add :order_id, :binary_id

      # id of the contractors given the job
      add :work_profile_id, references(:work_profiles, on_delete: :nothing, type: :binary_id)
      # id of the owner of the request
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:direct_hires, [:work_profile_id])
    create index(:direct_hires, [:user_id])
    create index(:direct_hires, [:order_id])
    create index(:direct_hires, [:is_accepted])
    create index(:direct_hires, [:is_assigned])
  end
end
