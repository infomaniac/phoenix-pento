defmodule Pento.SupportFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pento.Support` context.
  """

  @doc """
  Generate a faq.
  """
  def faq_fixture(attrs \\ %{}) do
    {:ok, faq} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        question: "some question",
        votes: 42
      })
      |> Pento.Support.create_faq()

    faq
  end
end
