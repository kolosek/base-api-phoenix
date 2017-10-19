defmodule CompanyApiWeb.ConversationView do
  use CompanyApiWeb, :view

  def render("create.json", %{conv: conv}) do
    render_one(conv, CompanyApiWeb.ConversationView, "conversation.json")
  end

  def render("conversation.json", %{conv: conv}) do
    %{id: conv.id, status: nil}
  end
end
