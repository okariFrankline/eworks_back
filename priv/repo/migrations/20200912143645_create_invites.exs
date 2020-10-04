defmodule Eworks.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :required_collaborators, :integer, default: 0, null: false
      add :deadline, :date, null: false
      add :duration, :string, null: false
      add :is_paid_for, :boolean, default: false
      add :payable_amount, :string, null: true
      add :payment_schedule, :string, null: true
      add :category, :string, null: false
      add :already_accepted, :integer, default: 0, null: false
      add :collaborators, {:array, :binary_id}, default: []

      # order for which the offer is for
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)
      # owner of the collaboration invite
      add :work_profile_id, references(:work_profile, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invites, [:work_profile_id])
    create index(:invites, [:order_id])
    create index(:invites, [:category])
    create index(:invites, [:is_paid_for])
    create index(:invites, [:inserted_at])
  end
end
