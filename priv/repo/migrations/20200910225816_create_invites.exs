defmodule Eworks.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :collaborators_needed, :integer
      add :deadline, :date
      add :duration, :string
      add :description, :string
      add :is_paid_for, :boolean, default: false
      add :is_verified, :boolean, default: false
      add :payable_amount, :string
      add :payment_schedule, :string
      add :title, :string
      add :verification_code, :integer
      add :invite_type, :string
      add :is_draft, :boolean, default: true
      # owner of the collaboration invite
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invites, [:user_id])
    create index(:invites, [:is_draft])
    create index(:invites, [:title])
    create index(:invites, [:is_paid_for])
    create index(:invites, [:is_verified])
  end
end
