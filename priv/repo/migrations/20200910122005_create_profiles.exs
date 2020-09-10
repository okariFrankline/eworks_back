defmodule Eworks.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: true
      add :last_name, :string, null: true
      add :company_name, :string, null: true
      add :country, :string, null: true
      add :city, :string, null: true
      add :emails, {:array, :string}, default: []
      add :phones, {:array, :string}, default: []
      add :skills, {:array, :string}, default: []
      add :about, :text, null: true
      add :profile_pic, :string, null: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:profiles, [:user_id])
    create index(:profiles, [:skills])
  end
end
