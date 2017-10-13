defmodule CompanyApi.Guardian do
  use Guardian, otp_app: :company_api

  alias CompanyApi.Repo
  alias CompanyApiWeb.User

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def subject_for_token(_) do
    {:error, "Unknown type"}
  end

  def resource_from_claims(claims) do
    {:ok, Repo.get_by(User, claims["sub"])}
  end

  def resource_from_claims(_) do
    {:error, "Unknown type"}
  end
end
