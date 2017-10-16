defmodule CompanyApiWeb.Conversation do
  use CompanyApiWeb, :model

  alias CompanyApiWeb.{User, Message}

  schema "conversations" do
    field :status, :string

    belongs_to :sender, User
    belongs_to :recipient, User
    has_many :messages, Message

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:sender_id, :recipient_id, :status])
    |> validate_required([:sender_id, :recipient_id])
    |> unique_constraint(:sender_id)
    |> unique_constraint(:recipient_id)
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:recipient_id)
  end
end
