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

  #scope "/", CompanyApiWeb do
  # pipe_through :browser # Use the default browser stack
  #
  # get "/", PageController, :index
  # end

   scope "/api", CompanyApiWeb do
     pipe_through :api

     resources "/users", CompanyApiWeb.UserController, only: [:index, :create]
   end
end
