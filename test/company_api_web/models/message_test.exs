defmodule CompanyApiWeb.MessagesTest do
  use CompanyApi.DataCase, async: true

  alias CompanyApiWeb.Message

  @valid_attributes %{sender_id: 1,
                      conversation_id: 1,
                      content: "This is the message.",
                      date: Ecto.DateTime.from_erl(:erlang.localtime)
                     }

  test "message with valid data" do
    message = Message.changeset(%Message{}, @valid_attributes)

    assert message.valid?
  end

  test "message with missing data" do
    message = Message.changeset(%Message{}, %{})

    refute message.valid?
  end
end

