defmodule CompanyApiWeb.Message do
  use CompanyApiWeb, :model

  alias CompanyApiWeb.{User, Conversation}

  schema "messages" do
    field :content, :string
    field :date, Ecto.DateTime

    belongs_to :conversation, Conversation
    belongs_to :sender, User, foreign_key: :sender_id

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:sender_id, :conversation_id, :content, :date])
    |> validate_required([:sender_id, :conversation_id, :content, :date])
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:conversation_id)
  end

  def create_message(user_id, conv_id, content) do
    message_data = %{sender_id: user_id,
                     conversation_id: conv_id,
                     content: content,
                     date: Ecto.DateTime.from_erl(:erlang.localtime)
                    }

    message = changeset(%__MODULE__{}, message_data)
    case CompanyApi.Repo.insert(message) do
      {:ok, message} ->
        message
      {:error, _error} ->
        nil
    end
  end
end
