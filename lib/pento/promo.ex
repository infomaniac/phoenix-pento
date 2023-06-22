defmodule Pento.Promo do
  alias Pento.Promo.Recipient

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  def send_promo(_recipient, attrs = %{"email" => email, "first_name" => first_name} \\ %{}) do
    IO.puts("Sending promo to #{first_name} on #{email}")

    r = change_recipient(%Recipient{}, attrs)
    {:ok, r}
  end
end
