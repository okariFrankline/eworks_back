defmodule Eworks.Repo.Migrations.CreateWorkProfiles do
  use Ecto.Migration

  def change do
    create table(:work_profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :float, default: 2.5
      add :success_rate, :float, default: 50.0
      add :skills, {:array, :string}, default: []
      add :professional_intro, :text, null: true
      add :job_hires, :integer, defualt: 0
      add :is_upgraded, :boolean, default: false
      add :assigned_orders, {:array, :binary_id}, default: []
      add :previous_hires, {:array, :binary_id}, default: []
      add :show_more, :boolean, default: false, null: false
      add :in_progress, :integer, default: 0, null: false
      add :un_paid, :integer, default: 0, null: false
      add :recently_paid, :integer, default: 0, null: false
      # date for indicating how long the upgraded status should last
      add :has_upgrade_expired, :boolean, default: false
      # add for indicating the date for which the upgrade was made
      add :last_upgraded_on, :utc_datetime, null: true
      # add indicating the date the upgrade would end
      add :upgrade_expiry_date, :utc_datetime, null: true
      # owner of the work profile
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:work_profiles, [:user_id])
    create index(:work_profiles, [:skills])
  end
end
