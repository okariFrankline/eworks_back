defmodule Eworks.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: true
      add :is_verified, :boolean, default: false, null: false
      add :is_assigned, :boolean, default: false, null: false
      add :is_complete, :boolean, default: false, null: false
      add :is_paid_for, :boolean, default: false, null: false
      add :is_cancelled, :booleand, default: false, null: false
      add :duration, :string, null: true
      add :deadline, :date, null: true
      add :order_type, :string, null: true
      add :category, :string, null: true
      add :payable_amount, :string, null: true
      add :required_contractors, :integer, null: true
      add :specialty, :string, null: true
      add :attachments, :string, null: true
      add :payment_schedule, :string, null: true
      add :verification_code, :integer, null: true
      add :is_draft, :boolean, default: true
      add :already_assigned, :integer, default: 0, null: false
      add :accepted_offers, :integer, default: 0, null: false
      add :assignees, {:array, :binary_id}, default: []
      add :tags, {:array, :binary_id}, default: []
      add :show_more, :boolean, default: false
      add :owner_name, :string
      add :is_public, :boolean, default: true, null: false
      # client comment and review
      add :comment, :text, null: true
      add :rating, :integer, null: true
      # owner of the job
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:orders, [:user_id])
    create index(:orders, [:is_draft])
    create index(:orders, [:is_verified])
    create index(:orders, [:is_assigned])
    create index(:orders, [:is_complete])
    create index(:orders, [:is_paid_for])
    create index(:orders, [:is_cancelled])
    create index(:orders, [:category])
    create index(:orders, [:order_type])
    create index(:orders, [:is_public])

  end
end
