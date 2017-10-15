defmodule Memz.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Memz.Accounts.User

  schema "users" do
    field(:name, :string)

    has_many(:events, Memz.Events.Event)
    has_many(:images, Memz.Events.Image)
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 30)
  end
end
