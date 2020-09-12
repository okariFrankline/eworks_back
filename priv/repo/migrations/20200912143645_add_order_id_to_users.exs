defmodule Eworks.Repo.Migrations.AddOrderIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # order for which this user has been assigned
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)
    end # end of altering table with users

    create index(:users, [:order_id])
  end
end
