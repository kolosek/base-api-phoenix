defmodule CompanyApiWeb.ChannelUsers do
  use GenServer

  #Client side

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def get_online_users(channel) do
    GenServer.call(__MODULE__, {:get_online_users, channel})
  end

  def user_joined(user, channel) do
    GenServer.cast(__MODULE__, {:user_joined, user, channel})
  end

  def user_leave(user, channel) do
    GenServer.cast(__MODULE__, {:user_leave, user, channel})
  end

  #Server callbacks

  def handle_call({:get_online_users, channel}, _from, online_users) do
    {:reply, Map.get(online_users, channel), online_users}
  end

  def handle_cast({:user_joined, channel, user}, _from, online_users) do
    new_state =
      case Map.get(online_users, channel) do
        nil ->
          Map.put(online_users, channel, [user])
        users ->
          Map.put(online_users, channel, Enum.uniq([user | users]))
      end

    {:noreply, new_state, new_state}
  end

  def handle_cast({:user_left, channel, user}, _from, online_users) do
    new_users =
      online_users
      |> Map.get(channel)
      |> Enum.reject(&(&1.id == user.id))

    new_state = Map.update!(online_users, channel, fn -> new_users end)

    {:noreply, new_state, new_state}
  end
end
