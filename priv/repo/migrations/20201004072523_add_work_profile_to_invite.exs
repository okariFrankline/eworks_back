defmodule Eworks.Repo.Migrations.AddWorkProfileToInvite do
  use Ecto.Migration

  def change do
    alter table(:invites) do
      # workprofile for the person who had been assigned this order and for which he/she completed and got paid for
      add :work_profile_id, references(:work_profiles, on_delete: :nothing, type: :binary_id)
    end # end of the alter table function

    create index(:invites, [:work_profile_id])
  end
end
