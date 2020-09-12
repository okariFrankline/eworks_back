defmodule Eworks.Repo.Migrations.CreateInviteOffers do
  use Ecto.Migration

  def change do
    create table(:invite_offers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :asking_amount, :integer
      add :is_pending, :boolean, default: false, null: false
      add :is_cancelled, :boolean, default: false, null: false
      add :is_rejected, :boolean, default: false, null: false
      add :is_accepted, :boolean, default: false, null: false
      # rlships
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :invite_id, references(:invites, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invite_offers, [:user_id])
    create index(:invite_offers, [:invite_id])
  end
end
