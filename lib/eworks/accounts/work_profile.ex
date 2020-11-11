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
    field :last_upgraded_on, :utc_datetime
    # field indicating the date the upgrade would end
    field :upgrade_expiry_date, :utc_datetime
    # field for indicating whether the upgrade of an account is expired
    field :has_upgrade_expired, :boolean, default: false
    field :job_hires, :integer
    field :professional_intro, :string
    field :rating, :float
    field :skills, {:array, :string}
    field :success_rate, :float
    field :show_more, :boolean, default: false
    field :in_progress, :integer, default: 0
    field :un_paid, :integer, default: 0
    field :recently_paid, :integer, default: 0
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
      :recently_paid,
      :un_paid,
      :in_progress
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

  # @doc false
  # def cover_letter_changeset(profile, attrs) do
  #   changeset(profile, attrs)
  #   # ensure the cover letter is give
  #   |> validate_required([
  #     :cover_letter
  #   ])
  # end # end of cover_letter changeset/2

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

  # function adding the upgrade information
  defp add_upgrade_information(%Changeset{valid?: true, changes: %{upgrade_duration: duration, duration_type: d_type}} = changeset) do
    # ensure the duration does not exceed two weeks
    if is_valid_duration?(duration, d_type) do
      # check the duration type
      case d_type do
        # the duration is days
        "Day(s)" ->
          # get the current date
          current_date = Timex.now()
          # set the expiry date to a date duration times ahead
          expiry_date = Timex.shift(current_date, days: duration)
          # put the changeset
          changeset
          # put the last_updated_on
          |> put_change(:last_upgraded_on, current_date)
          # set the expiry date on
          |> put_change(:upgrade_expiry_date, expiry_date)
          # set the is pugraded to true
          |> put_change(:is_upgraded, true)

        # the duration type is in weeks
        "Week(s)" ->
          # get the current date
          current_date = Timex.now()
          # set the expiry date
          expiry_date = Timex.shift(current_date, days: duration * 7)
          # put the changeset
          changeset
          # put the last_updated_on
          |> put_change(:last_upgraded_on, current_date)
          # set the expiry date on
          |> put_change(:upgrade_expiry_date, expiry_date)
          # set the is pugraded to true
          |> put_change(:is_upgraded, true)
      end # end of case for d_type
    else
      # the duration is not valid
      changeset
      # add en error to the duration
      |> add_error(:duration, "Failed. Total upgrade duration cannot be less than 1 day or exceed 2 weeks.")
    end
  end # end of add_upgrade_information
  defp add_upgrade_information(changeset), do: changeset

  # function for validating the information
  defp is_valid_duration?(duration, duration_type) when duration_type == "Day(s)" do
    # ensure the duration is not greater then 14
    cond do
      # duration is greater than 0
      duration <= 0 -> false
      # duration is greater than zero but less than 14
      duration <= 14 -> true
      # duration is greater than 14
      true -> false
    end # end of cond
  end # end of is_valid_duration
  # called when the duration type is weeks
  defp is_valid_duration?(duration, duration_type) do
    duration_length = "#{duration} #{duration_type}"
    # ensure the duration type is either 1 week or 2 weeks
    if duration_length != "1 Week(s)" or duration_length != "2 Week(s)", do: false, else: true
  end # end of is_valid duration type
  # function for adding the skills to the changeset
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
