defmodule Eworks.Repo.Migrations.CreateInviteOffers do
  use Ecto.Migration

  def change do
    create table(:invite_offers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_pending, :boolean, default: false, null: false
      add :has_accepted_invite, :boolean, default: false, null: false
      add :is_rejected, :boolean, default: false, null: false
      add :is_accepted, :boolean, default: false, null: false
      add :is_cancelled, :boolean, default: false, null: false

      add :owner_name, :string, null: false
      add :rating, :integer, null: false
      add :about, :text, null: false
      add :owner_profile_pic, :string, null: false,
      add :owner_job_success, :integer, default: 0, null: false
      # invite for which the offer is for
      add :invite_id, references(:invites, on_delete: :nothing, type: :binary_id)
      # owner of the offer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invite_offers, [:invite_id])
    create index(:invite_offers, [:user_id])
    create index(:invite_offers, [:is_pending])
    create index(:invite_offers, [:is_rejected])
    create index(:invite_offers, [:is_accepted])
    create index(:invite_offers, [:is_cancelled])
    create index(:invite_offers, [:has_accepted_invite])
  end
end
