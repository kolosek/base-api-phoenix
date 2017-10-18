defmodule CompanyApiWeb.ChatRoom do
  use CompanyApiWeb, :channel
  alias CompanyApi.{ChannelUsers, ChannelSessions}

  def join("room:chat", _payload, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    online_users =
      ChannelUsers.user_joined(user, "room:chat")
      |> Map.get("room:chat")

    send self(), {:update_users, online_users, user.id}

    {:ok, socket}
  end


  def handle_info({:update_users, online_users, user_id}, socket) do
    online_users
    |> Enum.filter(fn user -> user.id != user_id end)
    |> Enum.each(fn user ->
        push(ChannelSessions.get_socket(user.id),
                                      "update_users",
                                      %{users: online_users})
      end)

    {:noreply, socket}
  end
end
