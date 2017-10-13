defmodule CompanyApiWeb.UserController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.{User, Email}
  @pass_length 5

  def index(conn, _params) do
    users = Repo.all(User)

    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_data}) do
    params = Map.put(user_data, "password", generate_password())
    case Repo.insert(User.reg_changeset(%User{}, params)) do
      {:ok, user} ->
        spawn(fn() ->
          Task.Supervisor.start_child(EmailSupervisor, fn() ->
            Email.create_mail(user.password, user.email)
            |> CompanyApi.Mailer.deliver_later
          end)
        end)

        conn
        |> put_status(:created)
        |> render("create.json", user: user)
      {:error, user} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", user: user)
    end
  end

  defp generate_password do
    :crypto.strong_rand_bytes(@pass_length)
    |> Base.encode64
    |> binary_part(0, @pass_length)
  end
end
