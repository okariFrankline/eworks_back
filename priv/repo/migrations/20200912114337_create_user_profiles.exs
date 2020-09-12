defmodule Eworks.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # bio ddata
      add :first_name, :string, null: true
      add :last_name, :string, null: true
      add :company_name, :string, null: true
      add :profile_pic, :string, null: true
      add :about, :text, null: true
      # location information
      add :country, :string, null: true
      add :city, :string, null: true
      # contact information
      add :emails, {:array, :string}, default: []
      add :phones, {:array, :string}, default: []
      # skills that the user has
      add :skills, {:array, :string}, default: []
      # owner of the profile
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      # created_at and updated_at
      timestamps()
    end

    create index(:user_profiles, [:user_id])
    create index(:user_profiles, [:skills])
  endreate index(:user_profiles, [:user_id])
  end
end
