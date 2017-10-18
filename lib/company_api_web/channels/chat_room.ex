defmodule CompanyApiWeb.ChatRoom do
  use CompanyApiWeb, :channel

  alias CompanyApi.ChannelSessions
  def join("room:chat", _payload, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)

    send(self(), {:after_join, user.id})

    {:ok, socket}
  end

  def handle_in("send_msg", %{"user" => id, "message" => content}, socket) do
    socketz = ChannelSessions.get_socket id
    push socketz, "receive_msg", %{message: content}
    {:noreply, socket}
  end

  def handle_info({:after_join, user_id}, socket) do
    ChannelSessions.save_socket(user_id, socket)
    {:noreply, socket}
  end
end
