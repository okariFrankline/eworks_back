defmodule Eworks.Repo.Migrations.CreateOffersForOrders do
  use Ecto.Migration

  def change do
    create table(:order_offers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_pending, :boolean, default: false, null: false
      add :is_accepted, :boolean, default: false, null: false
      add :is_rejected, :boolean, default: false, null: false
      add :is_cancelled, :boolean, default: false, null: false
      add :asking_mount, :string, null: false
      # order for which the offer is for
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)
      # owner of the offer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:order_offers, [:order_id])
    create index(:order_offers, [:user_id])
    create index(:order_offers, [:is_pending])
    create index(:order_offers, [:is_rejected])
    create index(:order_offers, [:is_accepted])
    create index(:order_offers, [:is_cancelled])
  end
  
end
