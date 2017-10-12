defmodule CompanyApiWeb.UserTest do
  use CompanyApi.DataCase, async: true 

  alias CompanyApiWeb.User

  @valid_attributes %{name: "John", subname: "Doe", email: "doe@gmail.com", job: "web developer"} 
  @invalid_attributes %{}
  @invalid_email %{email: "mail.mail.com"}

  test "user with valid attributes" do
    user = User.reg_changeset(%User{}, @valid_attributes)

    assert user.valid?
  end
end
