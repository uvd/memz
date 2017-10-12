defmodule MemzWeb.Guardian do
  use Guardian, otp_app: :memz
  alias Memz.Accounts

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do

    %{"sub" => user_id} = claims

    {:ok, Accounts.get_user!(user_id)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end