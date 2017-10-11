defmodule Memz.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Memz.Repo
  alias Memz.Accounts.User

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do


    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()


  end

end
