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
      # is suspended
      add :is_suspended, :boolean, default: false
      # check of the profile is complete
      add :profile_complete, :boolean, default: false
      # is upgraded contractor
      add :is_upgraded_contractor, :boolean, default: false
      # full name
      add :full_name, :string, null: false
      # city
      add :city, :string, null: true
      # country
      add :country, :string, null: true
      # phone
      add :phone, :string, null: true
      # profile pic
      add :profile_pic, :string, null: true
      # saved workers
      add :saved_workers, {:array, :binary_id}, default: []

      timestamps()
    end

    create unique_index(:users, [:auth_email])
    create unique_index(:users, [:username])
    create unique_index(:users, [:phone])
    create index(:users, [:is_active])
    create index(:users, [:full_name])
    create index(:users, [:is_company])
    create index(:users, [:is_suspended])
    create index(:users, [:user_type])
    create index(:users, [:inserted_at])

  end
end
