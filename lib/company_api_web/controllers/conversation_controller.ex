defmodule CompanyApiWeb.ConversationController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.Conversation

  def create(conn, %{"conversation" => conv}) do
    user = Guardian.Plug.current_resource(conn)
    conversation =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: user.id, recipient_id: conv})

    case Repo.insert(conversation) do
      {:ok, conversation} ->
        conn
        |> put_status(:created)
        |> render("conversation.json", %{conv: conversation})
      {:error, error_conv} ->
        existing_conv = Repo.get!(Conversation, conv.id)
        conn
        |> render("conversation.json", %{conv: existing_conv})
    end
  end
end
