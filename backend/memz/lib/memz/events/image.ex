defmodule Memz.Events.Image do
  @moduledoc false

  use Arc.Ecto.Schema

  use Ecto.Schema
  import Ecto.Changeset

  alias Memz.Accounts.User
  alias Memz.Events.Event

  schema "images" do
    field :file, Memz.Events.Uploader.Type

    belongs_to :user, User
    belongs_to :event, Event

    timestamps()
  end

  @doc """
  Creates a changeset based on the `data` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(image, params \\ :invalid) do

    IO.inspect(params)

    image
    |> cast(params, [:user_id, :event_id])
    |> cast_attachments(params, [:file])
    |> validate_required([:user_id, :event_id])
  end

  def dummy_changeset(image, params \\ :invalid) do

    IO.inspect(params)

    image
    |> cast(params, [:user_id, :event_id, :file])
    |> validate_required([:user_id, :event_id, :file])
  end
end
