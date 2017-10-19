defmodule CompanyApiWeb.ChatRoomTest do
  use CompanyApiWeb.ChannelCase

  alias CompanyApi.Guardian, as: Guard
  alias CompanyApi.ChannelSessions
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

    {:ok, token, _claims} = Guard.encode_and_sign(user)

    {:ok, soc} = connect(UserSocket, %{"token" => token})
    {:ok, _, socket} = subscribe_and_join(soc, ChatRoom, "room:chat")

    {:ok, socket: socket, user: user}
  end

  test "checks messaging", %{socket: socket, user: u} do
    user =
      %User{}
      |> User.reg_changeset(@second_user_data)
      |> Repo.insert!

    {:ok, token, _claims} = Guard.encode_and_sign(user)
    {:ok, soc} = connect(UserSocket, %{"token" => token})

    {:ok, _, socketz} = subscribe_and_join(soc, ChatRoom, "room:chat")

    push socket, "send_msg", %{user: user.id, message: "Hi! This is message"}
    assert_push "receive_msg", %{message: content}
    assert content == "Hi! This is message"

    push socketz, "send_msg", %{user: u.id, message: "This is a reply"}
    assert_push "receive_msg", %{message: reply}
    assert reply == "This is a reply"
  end

  test "opens two connections by the same user", %{socket: _socket, user: user} do
    {:ok, token, _claims} = Guard.encode_and_sign(user)

    {:ok, soc} = connect(UserSocket, %{"token" => token})
    {:ok, _, socketz} = subscribe_and_join(soc, ChatRoom, "room:chat")

    new_user =
      %User{}
      |> User.reg_changeset(@second_user_data)
      |> Repo.insert!

    {:ok, new_token, _claims} = Guard.encode_and_sign(new_user)
    {:ok, soc} = connect(UserSocket, %{"token" => new_token})

    {:ok, _, _new_socketz} = subscribe_and_join(soc, ChatRoom, "room:chat")

    push socketz, "send_msg", %{user: new_user.id, message: "Sending from other client"}
    assert_push "receive_msg", %{message: _content}
  end

  test "terminates connection", %{socket: socket} do
    Process.unlink(socket.channel_pid)
    user = Guardian.Phoenix.Socket.current_resource(socket)

    close socket

    push socket, "send_msg", %{user: user.id, message: "Self destruct"}

    refute_push "receive_msg", %{message: "This shouldn't work"}
    assert ChannelSessions.get_socket(user.id) == nil
  end
end
