defmodule Eworks.Accounts.WorkProfile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

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
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # has many previous hires
    timestamps()
  end

  @doc false
  def changeset(work_profile, attrs) do
    work_profile
    |> cast(attrs, [
      :rating,
      :success_rate,
      :skills,
      :professional_intro,
      :job_hires,
      :cover_letter
    ])
  end

  @doc false
  def skills_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure the skiils is given
    |> validate_required([
      :skills
    ])
    # add the skills to the skills already in the changeset
    |> add_to_skills()
  end # end of the skills_changeset/2

  @doc false
  def cover_letter_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure the cover letter is give
    |> validate_required([
      :cover_letter
    ])
  end # end of cover_letter changeset/2

  @doc false
  def professional_intro_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure the cover letter is give
    |> validate_required([
      :professional_into
    ])
  end # end of cover_letter changeset/2

  # function for adding the skills to the changeset
  def add_to_skills(%Changeset{valid?: true, changes: %{skills: new_skills}, data: %__MODULE__{skills: saved_skills}} = changeset) do
    # check that any of the elements in the new skills is not in the saved skills
    to_save_skills = Enum.map(new_skills, fn skill ->
      # return the skill if its not in the saved skilled
      if not Enum.member?(saved_skills, skill), do: skill
    end)
    # check if the skills to save have any value
    if to_save_skills !== [] do
      # add the new skiils to the already saved skills
      changeset |> put_change(:skills, [to_save_skills | saved_skills])
    else
      # set the changeset action to nil to prevent any update
      changeset |> put_change(:action, nil)
    end # end of if
  end # end of add_to_skills/1
  def add_to_skills(changeset), do: changeset

end # end of the module
