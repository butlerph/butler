defmodule Butler.DaySchedules.Day do
  use Ecto.Schema
  import Ecto.Changeset

  alias Butler.Accounts.User

  @primary_key {:id, :binary_id, read_after_writes: true}
  @foreign_key_type :binary_id
  schema "days" do
    field :date, :utc_datetime
    field :selected_slots, {:array, :integer}, default: []

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:date, :user_id, :selected_slots])
    |> validate_required([:date, :user_id, :selected_slots])
    |> unique_constraint(:user_id_date, name: :user_id_date)
  end
end
