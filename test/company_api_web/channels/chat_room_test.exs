defmodule CompanyApiWeb.ChatRoomTest do
  use CompanyApiWeb.ChannelCase

  alias CompanyApi.Guardian
  alias CompanyApiWeb.{ChatRoom, UserSocket}

  @user_data %{ name:    "John",
                subname: "Doe",
                email:   "doe@gmail.com",
                job:     "engineer"
              }

  setup do
    user =
      %User{}
      |> User.reg_changeset(@user_data)
      |> Repo.insert!

    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    {:ok, token: token}
  end

  test "give me a dot", %{token: token} do
    {:ok, socket} = connect(UserSocket, %{"token" => token})
    {:ok, _, socket} = subscribe_and_join(socket, ChatRoom, "room:chat")
  end
end
