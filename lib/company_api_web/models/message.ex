defmodule CompanyApiWeb.Message do
  use CompanyApiWeb, :model

  alias CompanyApiWeb.{User, Conversation}

  schema "messages" do
    field :content, :string
    field :date, Ecto.DateTime

    belongs_to :conversation, Conversation
    belongs_to :sender, User

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:sender_id, :conversation_id, :content, :date])
    |> validate_required([:sender_id, :conversation_id, :content, :date])
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:conversation_id)
  end
end
