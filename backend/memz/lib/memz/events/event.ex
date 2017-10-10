defmodule Memz.Events.Event.NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end

defmodule Memz.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Memz.Events.Event
  alias Memz.Events.Event.NameSlug

  schema "events" do
    field :end_date, :naive_datetime
    field :name, :string
    field :slug, NameSlug.Type
    field :owner, :string

    timestamps()
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:name, :owner, :end_date])
    |> validate_required([:name, :owner, :end_date])
    |> validate_length(:name, min: 4, max: 20)
    |> validate_length(:owner, min: 2, max: 30)
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