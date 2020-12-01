defmodule Eworks.Accounts.WorkProfile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "work_profiles" do
    field :is_upgraded, :boolean, default: false
    # date for indicating how long the upgraded status should last
    field :upgrade_duration, :string, virtual: true
    # field for indicating the date for which the upgrade was made
    field :last_upgraded_on, :date
    # field indicating the date the upgrade would end
    field :upgrade_expiry_date, :date
    # field for indicating whether the upgrade of an account is expired
    field :has_upgrade_expired, :boolean, default: false
    field :job_hires, :integer
    field :professional_intro, :string
    field :rating, :float
    field :skills, {:array, :string}
    field :success_rate, :float
    field :show_more, :boolean, default: false
    # has many assigned orders
    field :assigned_orders, {:array, :binary_id}
    # embeds many previous hires
    field :previous_hires, {:array, :binary_id}
    # belongs to one user
    belongs_to :user, Eworks.Accounts.User, type: :binary_id
    # has many collaboration invites
    has_many :invites, Eworks.Collaborations.Invite
    # has many direct hire requests created
    has_many :direct_hires, Eworks.Requests.DirectHire
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
      :is_upgraded,
      :upgrade_duration,
      :last_upgraded_on,
      :upgrade_expiry_date,
      :has_upgrade_expired,
      :assigned_orders,
      :show_more,
      :previous_hires
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
  def professional_intro_changeset(profile, attrs) do
    changeset(profile, attrs)
    # ensure the cover letter is give
    |> validate_required([
      :professional_intro
    ])
  end # end of cover_letter changeset/2

  @doc false
  def upgrade_changeset(profile, attrs) do
    changeset(profile, attrs)
    # cast the upgrade_duration
    |> cast(attrs, [
      :upgrade_duration
    ])
    # validate the required fields
    |> validate_required([
      :upgrade_duration
    ])
    # add the upgrade dates
    |> add_upgrade_information()
    # ensure the user id is given
    |> foreign_key_constraint(:user_id)
  end # end of upgrade_changeset/2

  # function for adding upgrade information
  defp add_upgrade_information(%Changeset{valid?: true, changes: %{upgrade_duration: duration}} = changeset) do
    # get the current date
    current_date = Timex.now()
    # set the expiration date to duration + 1 day after the current date
    expiry_date = Timex.shift(current_date, days: duration + 1)
    # convert the date time to date
    |> DateTime.to_date()
    # update the changeset
    changeset
    # set the date of last upgrade
    |> put_change(:last_upgrade, DateTime.to_date(current_date))
    # set the expiry date
    |> put_change(:upgrade_expiry_date, expiry_date)
    # set the has upgrade expired to false
    |> put_change(:has_upgrade_expired, false)
  end # end of add upgrade inforamtion
  defp add_upgrade_information(changeset), do: changeset

  def add_to_skills(%Changeset{valid?: true, changes: %{skills: new_skills}, data: %__MODULE__{skills: saved_skills}} = changeset) do
    # check that any of the elements in the new skills is not in the saved skills
    to_save_skills = Enum.filter(new_skills, fn skill -> not Enum.member?(saved_skills, skill) end)
    # check if the skills to save have any value
    if not Enum.empty?(to_save_skills) do
      # add the new skiils to the already saved skills
      changeset |> put_change(:skills, Enum.concat(to_save_skills, saved_skills))
    else
      # set the changeset action to nil to prevent any update
      changeset |> put_change(:skills, nil)
    end # end of if
  end # end of add_to_skills/1
  def add_to_skills(changeset), do: changeset

end # end of the module
