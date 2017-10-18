defmodule CompanyApiWeb.ChatRoomTest do
  use CompanyApiWeb.ChannelCase

  alias CompanyApi.{Guardian, ChannelSessions}
  alias CompanyApiWeb.{ChatRoom, UserSocket}

  @first_user_data %{ name:    "John",
                      subname: "Doe",
                      email:   "doe@gmail.com",
                      job:     "engineer"
                    }

  @second_user_data %{ name:    "Jane",
                       subname: "Doe",
                       email:   "jane@gmail.com",
                       job:     "architect"
                     }

  setup do
    ChannelSessions.clear

    user =
      %User{}
      |> User.reg_changeset(@first_user_data)
      |> Repo.insert!

    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    {:ok, soc} = connect(UserSocket, %{"token" => token})
    {:ok, _, socket} = subscribe_and_join(soc, ChatRoom, "room:chat")

    {:ok, socket: socket, user: user}
  end

  test "checks reply for online users", %{socket: socket, user: u} do
    user =
      %User{}
      |> User.reg_changeset(@second_user_data)
      |> Repo.insert!

    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    {:ok, soc} = connect(UserSocket, %{"token" => token})

    {:ok, _, socketz} = subscribe_and_join(soc, ChatRoom, "room:chat")

    push socket, "send_msg", %{user: user.id, message: "Hi! This is message"}
    assert_push "receive_msg", %{message: content}
    assert content == "Hi! This is message"

    push socketz, "send_msg", %{user: u.id, message: "This is a reply"}
    assert_push "receive_msg", %{message: reply}
    assert reply == "This is a reply"
  end
end
