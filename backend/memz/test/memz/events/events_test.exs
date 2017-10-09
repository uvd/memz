defmodule Memz.EventsTest do
  use Memz.DataCase

  alias Memz.Events

  describe "events" do
    alias Memz.Events.Event

    @valid_attrs %{end_date: ~N[2020-04-17 14:00:00.000000], name: "some name", owner: "some owner"}
    @update_attrs %{end_date: ~N[2021-05-18 15:01:01.000000], name: "some updated name", owner: "some updated owner"}
    @invalid_attrs %{end_date: nil, name: nil, owner: nil}

    @invalid_name_too_short %{@valid_attrs | name: "som"}
    @invalid_name_too_long %{@valid_attrs | name: generate_string_of_length(21) }
    @invalid_owner_too_short %{@valid_attrs | owner: "a"}
    @invalid_owner_too_long %{@valid_attrs | owner: generate_string_of_length(31) }

    @invalid_end_date_pure_banter %{@valid_attrs | end_date: "blah"}
    @invalid_end_date_in_the_past %{@valid_attrs | end_date: ~N[2015-05-18 15:04:02.000000]}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create_event()

      event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create_event(@valid_attrs)
      assert event.end_date == ~N[2020-04-17 14:00:00.000000]
      assert event.name == "some name"
      assert event.owner == "some owner"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "create_event/1 with a name that is too short returns error changeset" do
      {:error, changeset} = Events.create_event(@invalid_name_too_short)
      assert {"should be at least %{count} character(s)", [count: 4, validation: :length, min: 4]} = changeset.errors[:name]
    end

    test "create_event/1 with a name that is too long returns error changeset" do
      {:error, changeset} = Events.create_event(@invalid_name_too_long)
      assert {"should be at most %{count} character(s)", [count: 20, validation: :length, max: 20]} = changeset.errors[:name]
    end

    test "create_event/1 with an owner which is too short return error changeset" do
      {:error, changeset} = Events.create_event(@invalid_owner_too_short)
      assert {"should be at least %{count} character(s)", [count: 2, validation: :length, min: 2]} = changeset.errors[:owner]
    end

    test "create_event/1 with an owner which is too long return error changeset" do
      {:error, changeset} = Events.create_event(@invalid_owner_too_long)
      assert {"should be at most %{count} character(s)", [count: 30, validation: :length, max: 30]} = changeset.errors[:owner]
    end

    test "create_event/1 with an end_date which is not a date string" do
      {:error, changeset} = Events.create_event(@invalid_end_date_pure_banter)
      assert {"is invalid", [type: :naive_datetime, validation: :cast]} = changeset.errors[:end_date]
    end

    test "create_event/1 with an end_date in the past return error changeset" do
      {:error, changeset} = Events.create_event(@invalid_end_date_in_the_past)
      assert {"Time must be in the future", []} = changeset.errors[:end_date]
    end

  end

end
