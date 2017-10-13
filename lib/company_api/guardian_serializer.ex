defmodule CompanyApi.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias CompanyApi.Repo
  alias CompanyApiWeb.User

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown type"}

  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Can't fetch user from database"}
end
