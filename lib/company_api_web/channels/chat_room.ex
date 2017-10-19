defmodule CompanyApiWeb.ChatRoom do
  use CompanyApiWeb, :channel

  alias CompanyApi.{ChannelSessions, ChannelUsers}

  def join("room:chat", _payload, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    send(self(), {:after_join, user})

    {:ok, socket}
  end

  def handle_in("send_msg", %{"user" => id, "message" => content}, socket) do
    case ChannelSessions.get_socket id do
      nil ->
        {:error, socket}
      socketz ->
        push socketz, "receive_msg", %{message: content}
        {:noreply, socket}
    end
  end

  def handle_info({:after_join, user}, socket) do
    ChannelSessions.save_socket(user.id, socket)
    ChannelUsers.user_joined(user, "room:chat")

    {:noreply, socket}
  end

  def terminate(_msg, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    ChannelSessions.delete_socket user.id
    ChannelUsers.user_leave(user, "room:chat")
  end
end
