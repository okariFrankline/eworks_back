defmodule Eworks.Repo.Migrations.CreateDirectHires do
  use Ecto.Migration

  def change do
    create table(:direct_hires, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_accepted, :boolean, default: false, null: false
      add :is_pending, :boolean, default: true, null: false
      add :is_rejected, :boolean, default: false, null: false
      add :is_cancelled, :boolean, default: false, null: false

      # id of the contractors giv en the job
      add :work_profile_id, references(:work_profiles, on_delete: :nothing, type: :binary_id)
      # id of the owner of the request
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      # id of the order
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:direct_hires, [:work_profile_id])
    create index(:direct_hires, [:user_id])
    create index(:direct_hires, [:order_id])
    create index(:direct_hires, [:is_accepted])
    create index(:direct_hires, [:is_pending])
    create index(:direct_hires, [:is_rejected])
  end
end
