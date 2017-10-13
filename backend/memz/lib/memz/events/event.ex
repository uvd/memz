defmodule Memz.Events.Event.NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end

defmodule Memz.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Memz.Events.Event
  alias Memz.Events.Event.NameSlug
  alias Memz.Accounts.User

  schema "events" do
    field :name, :string
    field :end_date, :naive_datetime
    field :slug, NameSlug.Type

    belongs_to :user, User
    has_many :images, Memz.Events.Image

    timestamps()
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:name, :end_date, :user_id])
    |> validate_required([:name, :end_date, :user_id])
    |> validate_length(:name, min: 4, max: 20)
    |> validate_date_in_future(:end_date)
    |> NameSlug.maybe_generate_slug
  end

  def validate_date_in_future(changeset, field) do

    validate_change(changeset, field, fn _, end_date ->

        now = Ecto.DateTime.utc
        {:ok, target_date} = Ecto.DateTime.cast(end_date)

        case Ecto.DateTime.compare(now, target_date) do
          :gt -> [{field, "Time must be in the future"}]
          _ -> []
        end

    end)

  end

end