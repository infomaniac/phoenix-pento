defmodule Pento.Support.FAQ do
  use Ecto.Schema
  import Ecto.Changeset

  schema "faqs" do
    field :answer, :string
    field :question, :string
    field :votes, :integer

    timestamps()
  end

  @doc false
  def changeset(faq, attrs) do
    faq
    |> cast(attrs, [:question, :answer, :votes])
    |> validate_required([:question, :answer, :votes])
  end
end
