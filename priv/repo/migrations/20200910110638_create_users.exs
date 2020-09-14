defmodule Eworks.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # authentication email of the user
      add :auth_email, :string, null: false
      # hashed password
      add :password_hash, :string, null: false
      # indicates whether the user is logged in or note
      add :is_active, :boolean, default: false, null: false
      # indicates the type of user that the user is
      add :user_type, :string, defualt: "Client"
      # activation code: a 6 digit figure that is sent to the user upon successful creation of an account
      add :activation_key, :integer, null: true
      # unique username
      add :username, :string, null: false
      # is_company
      add :is_company, :boolean ,default: false
      # full name
      add :full_name, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:auth_email])
    create unique_index(:users, [:username])
    create index(:users, [:is_active])
    create index(:users, [:full_name])
    create index(:users, [:is_company])

  end
end
