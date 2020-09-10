defmodule Eworks.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :auth_email, :string, null: false
      add :password_hash, :string, null: false
      add :is_active, :boolean, default: false, null: false
      add :user_type, :string, defualt: "Client"
      add :activation_key, :integer, null: true
      add :username, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:auth_email])
    create unique_index(:users, [:username])
    create index(:users, [:is_active])

  end
end
