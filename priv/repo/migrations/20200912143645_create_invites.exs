defmodule Eworks.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :required_collaborators, :integer, default: 1, null: false
      add :deadline, :date, null: true
      add :is_paid_for, :boolean, default: false
      add :is_cancelled, :boolean, default: false, null: false
      add :is_assigned, :boolean, default: false, null: false
      add :is_draft, :boolean, default: true, null: false
      add :payable_amount, :string, null: true
      add :payment_schedule, :string, null: true
      add :category, :string, null: false
      add :owner_name, :string, null: false
      add :specialty, :string, null: false
      add :show_more, :boolean, default: false, null: false
      add :description, :text, null: true
      add :verification_code, :integer, null: true
      add :collaborators, {:array, :binary_id}, default: []
      add :order_id, :binary_id

      # owner of the collaboration invite
      add :work_profile_id, references(:work_profiles, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invites, [:work_profile_id])
    create index(:invites, [:order_id])
    create index(:invites, [:category])
    create index(:invites, [:is_paid_for])
    create index(:invites, [:inserted_at])
    create index(:invites, [:is_cancelled])
    create index(:invites, [:is_assigned])
    create index(:invites, [:is_draft])
  end
end
