defmodule Eworks.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :payable_amount, :string
      add :deadline, :date
      add :is_verified, :boolean, default: false, null: false
      add :verification_code, :integer
      add :is_paid_for, :boolean, default: false, null: false
      add :collaborators_needed, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invites, [:user_id])
  end
end
