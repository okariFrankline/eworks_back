defmodule Eworks.Repo.Migrations.CreateAssignedOrders do
  use Ecto.Migration

  def change do
    create table(:assigned_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # user id
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end # end of the create table

    # index for the user id
    create index(:assigned_orders, [:user_id])

  end
end
