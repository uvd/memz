defmodule Memz.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Memz.Repo

  alias Memz.Events.Event
  alias Memz.Events.Image
  alias Memz.Accounts.User

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id) do

    Repo.one(
      from event in Event,
      join: u in assoc(event, :user),
      where: event.id == ^id,
      preload: [:user]
    )

  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do

    %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()

  end


  @doc """
  Creates a image for a user and an event.

  ## Examples

      iex> create_image(%{field: value}, event, user)
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(file, event, user) do

    IO.inspect(file)

    %Image{}
      |> Image.changeset(%{file: file, user_id: user.id, event_id: event.id})
      |> Repo.insert()

  end


  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end
end
