defmodule Eworks.Repo.Migrations.CreateWorkProfiles do
  use Ecto.Migration

  def change do
    create table(:work_profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :integer, default: 0
      add :success_rate, :integer, default: 0
      add :skills, {:array, :string}, default: []
      add :professional_intro, :text, null: true
      add :cover_letter, :text, null: true
      add :job_hires, :integer, defualt: 0
      # owner of the work profile
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:work_profiles, [:user_id])
    create index(:work_profiles, [:cover_letter])
    create index(:work_profiles, [:skills])
  end
end
