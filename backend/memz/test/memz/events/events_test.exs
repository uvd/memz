defmodule Memz.EventsTest do
  use Memz.DataCase

  alias Memz.Events
  alias Memz.Accounts.User
  alias Memz.Repo

  describe "events" do
    alias Memz.Events.Event

    @valid_attrs %{end_date: ~N[2020-04-17 14:00:00.000000], name: "some name"}
    @invalid_attrs %{end_date: nil, name: nil, owner: nil}

    @invalid_name_too_short %{@valid_attrs | name: "som"}
    @invalid_name_too_long %{@valid_attrs | name: generate_string_of_length(21) }

    @invalid_end_date_pure_banter %{@valid_attrs | end_date: "blah"}
    @invalid_end_date_in_the_past %{@valid_attrs | end_date: ~N[2015-05-18 15:04:02.000000]}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create_event()

      event
    end

    def attrs_with_user_id(attrs) do

      {:ok, user } =
        %User{}
          |> User.changeset(%{ "name" => "Jane" })
          |> Repo.insert()

      Map.put(attrs, :user_id, user.id)

    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create_event(attrs_with_user_id(@valid_attrs))

      event = Repo.preload(event, :user)

      assert event.end_date == ~N[2020-04-17 14:00:00.000000]
      assert event.name == "some name"
      assert event.user.name == "Jane"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "create_event/1 with a name that is too short returns error changeset" do
      {:error, changeset} = Events.create_event(attrs_with_user_id(@invalid_name_too_short))
      assert {"should be at least %{count} character(s)", [count: 4, validation: :length, min: 4]} = changeset.errors[:name]
    end

    test "create_event/1 with a name that is too long returns error changeset" do
      {:error, changeset} = Events.create_event(attrs_with_user_id(@invalid_name_too_long))
      assert {"should be at most %{count} character(s)", [count: 20, validation: :length, max: 20]} = changeset.errors[:name]
    end

    test "create_event/1 with an end_date which is not a date string" do
      {:error, changeset} = Events.create_event(attrs_with_user_id(@invalid_end_date_pure_banter))
      assert {"is invalid", [type: :naive_datetime, validation: :cast]} = changeset.errors[:end_date]
    end

    test "create_event/1 with an end_date in the past return error changeset" do
      {:error, changeset} = Events.create_event(attrs_with_user_id(@invalid_end_date_in_the_past))
      assert {"Time must be in the future", []} = changeset.errors[:end_date]
    end

  end

end
