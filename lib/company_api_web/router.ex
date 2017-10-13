defmodule CompanyApiWeb.Router do
  use CompanyApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: CompanyApi.GuardianErrorHandler
  end

  if Mix.env == :dev do
    forward "/send_mails", Bamboo.EmailPreviewPlug
  end

   scope "/api", CompanyApiWeb do
     pipe_through :api

     resources "/users", UserController, only: [:index, :create]
     put("/users/:id", UserController, :change_password)

     post "/login", SessionController, :create
   end

   scope "/api", CompanyApiWeb do
     pipe_through [:api, :auth]

     delete "/logout", SessionController, :delete
   end
end
