defmodule CompanyApiWeb.User do
  use CompanyApiWeb, :model

  alias CompanyApi.Repo
  @pass_length 15

  schema "users" do
    field :name, :string
    field :subname, :string
    field :email, :string
    field :password, :string
    field :job, :string

    timestamps()
  end

  def reg_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :subname, :email, :job, :password])
    |> validate_required([:name, :subname, :email, :job])
    |> validate_format(:email, ~r/\S+@\S+\.\S+/)
  end

  def pass_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :subname, :email, :job, :password])
    |> validate_required([:name, :subname, :email, :job, :password])
    |> validate_format(:email, ~r/\S+@\S+\.\S+/)
    |> validate_length(:password, min: 6)
  end

  def generate_password do
    :crypto.strong_rand_bytes(@pass_length)
    |> Base.encode64
    |> binary_part(0, @pass_length)
  end

  def check_registration(params) do
    case Repo.get_by(__MODULE__, params) do
      user when user != nil -> {:ok, user}
      nil -> {:error, "No user with these credentials"}
    end
  end
end
