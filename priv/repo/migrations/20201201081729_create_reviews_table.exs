defmodule Eworks.Repo.Migrations.CreateReviewsTable do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :float, null: false, default: 0.0
      add :comment, :text, null: false

      add :order_id, references(:orders, type: :binary_id, on_delete: :nothing)
      add :user_id, references(:users, type: :binary_id, on_delete: :nothing)

      timestamps()
    end # end of create table

    create index(:reviews, [:order_id])
    create index(:reviews, [:user_id])
  end
end
