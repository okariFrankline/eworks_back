defmodule Eworks.Profiles.WorkProfile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "work_profiles" do
    field :cover_letter, :string
    field :job_hires, :integer
    field :professional_intro, :string
    field :rating, :integer
    field :skills, {:array, :string}
    field :success_rate, :integer
    # embeds many previous hires
    has_many :previous_hires, __MODULE__.PreviousHires
    # belongs to one user
    belongs_to :user, Eworks.Profiles.User, type: :binary_id
    # has many previous hires
    timestamps()
  end

  @doc false
  def changeset(work_profile, attrs) do
    work_profile
    |> cast(attrs, [:rating, :success_rate, :skills, :professional_intro, :job_hires, :cover_letter])
    |> validate_required([:rating, :success_rate, :skills, :professional_intro, :job_hires, :cover_letter])
  end
end
