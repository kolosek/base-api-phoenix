defmodule CompanyApiWeb.MessagesTest do
  use CompanyApi.DataCase, async: true

  alias CompanyApiWeb.{Message, User, Conversation}

  @valid_attributes %{sender_id: 1,
                      conversation_id: 1,
                      content: "This is the message.",
                      date: Ecto.DateTime.from_erl(:erlang.localtime)
                     }

  @user_one %{name:    "John",
              subname: "Doe",
              email:   "doe@gmail.com",
              job:     "engineer"
             }

  @user_two %{name:    "Jane",
              subname: "Doe",
              email:   "jane@gmail.com",
              job:     "architect"
             }

  setup do
    user_one =
      %User{}
      |> User.reg_changeset(@user_one)
      |> Repo.insert!

    user_two =
      %User{}
      |> User.reg_changeset(@user_two)
      |> Repo.insert!

    conversation =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: user_one.id,
                                  recipient_id: user_two.id
                                 }
      |> Repo.insert!

    {:ok, user: user_one, conv: conv}
  end

  test "message with valid data" do
    message = Message.changeset(%Message{}, @valid_attributes)

    assert message.valid?
  end

  test "message with missing data" do
    message = Message.changeset(%Message{}, %{})

    refute message.valid?
  end

  test "message creation", %{user: user, conv: conv} do

  end
end

