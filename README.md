# CompanyApi - Elixir api guide

  Elixir represents relatively new programming language for wider audience. It was published back in 2011, and is in development ever since. His main trait is that adops functional pardigm because it is built atop of Erlang and runs on BEAM(Erlang VM). 
Elixir is designed for building fast, scalable and maintainable applications and with Phoenix these applications can be developed in web environment. Phoenix is web framework written in Elixir and it draws a lot of concepts from popular frameworks like Python's Django or Ruby on Rails. If you are familiar with those that is a nice starting point.

# Documentation
  Elixir/Phoenix is a great combination, but before starting writing an app, those who are not familiar with all concepts should first read following documentation.
* [Elixir](https://elixir-lang.org/) - Detail documentation, from Elixir basic types to advanced stuff like Mix and OTP. Also [Programming Elixir](https://pragprog.com/book/elixir/programming-elixir) by Dave Thomas is recommendation,
* [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) - Built-in framework for testing,
* [Phoenix](http://phoenixframework.org/) - Phoenix framework documentation with all concepts explained with examples and
* [Ecto](https://hexdocs.pm/ecto/Ecto.html) - Docs and API for Elixir's ORM.

# Setting up application
  Elixir ships with Mix which is built-in tool that helps compiling, generating and testing application, getting dependencies etc.
We create our application by running `mix phx.new company_api`.
This tells mix to create new Phenix app named *company_api*. After running this instruction mix will create application structure:
```
* creating company_api/config/config.exs
* creating company_api/config/dev.exs
* creating company_api/config/prod.exs
* creating company_api/config/prod.secret.exs
* creating company_api/config/test.exs
* creating company_api/lib/company_api/application.ex
* creating company_api/lib/company_api.ex
* creating company_api/lib/company_api_web/channels/user_socket.ex
* creating company_api/lib/company_api_web/views/error_helpers.ex
* creating company_api/lib/company_api_web/views/error_view.ex
* creating company_api/lib/company_api_web/endpoint.ex
* creating company_api/lib/company_api_web/router.ex
* creating company_api/lib/company_api_web.ex
* creating company_api/mix.exs
* creating company_api/README.md
* creating company_api/test/support/channel_case.ex
* creating company_api/test/support/conn_case.ex
* creating company_api/test/test_helper.exs
* creating company_api/test/company_api_web/views/error_view_test.exs
* creating company_api/lib/company_api_web/gettext.ex
* creating company_api/priv/gettext/en/LC_MESSAGES/errors.po
* creating company_api/priv/gettext/errors.pot
* creating company_api/lib/company_api/repo.ex
* creating company_api/priv/repo/seeds.exs
* creating company_api/test/support/data_case.ex
* creating company_api/lib/company_api_web/controllers/page_controller.ex
* creating company_api/lib/company_api_web/templates/layout/app.html.eex
* creating company_api/lib/company_api_web/templates/page/index.html.eex
* creating company_api/lib/company_api_web/views/layout_view.ex
* creating company_api/lib/company_api_web/views/page_view.ex
* creating company_api/test/company_api_web/controllers/page_controller_test.exs
* creating company_api/test/company_api_web/views/layout_view_test.exs
* creating company_api/test/company_api_web/views/page_view_test.exs
* creating company_api/.gitignore
* creating company_api/assets/brunch-config.js
* creating company_api/assets/css/app.css
* creating company_api/assets/css/phoenix.css
* creating company_api/assets/js/app.js
* creating company_api/assets/js/socket.js
* creating company_api/assets/package.json
* creating company_api/assets/static/robots.txt
* creating company_api/assets/static/images/phoenix.png
* creating company_api/assets/static/favicon.ico
```
Install additional dependencies if prompted. Next we need to configure our database. In this example we used PostgreSQL, and generally Phoenix has best integration with this DBMS.
Open *companyapi/config/dev.exs* and *companyapi/config/test.exs* and setup username, password and database name. After setting up database, run `mix ecto.create` which will create development and test databases and after that `mix phx.server`. That should start server(Cowboy) on default port 4000. Check it up in browser, if you see landing page that's it, setup is good.
All configurations are placed in *company_api/config/config.exs* file. 

# Creating API
Before coding there are several parts of development that are going to be explained:
* Writing tests using ExUnit, testing both models and controlers,
* Writing migrations,
* Writing models,
* Writing controllers,
* Routing,
* Writing views,
* Authentication using Guardian and
* Channels.

Note that following parts won't be described for whole application, but you'll get the idea. 

## Testing and writing models
  While developing we want to write clean code that works, also think about specification and what that code needs to do before implementing it. That's why we're using [TDD](http://agiledata.org/essays/tdd.html) approach.
First in directory *test/companyapiweb/* create models directory and then create user_test.exs. After that create a module: 
```
defmodule CompanyApiWeb.UserTest do
    use CompanyApi.DataCase, async: true
end
```
On second line, we use macro *use* to inject some external code, in this case data_case.exs script that is placed in *test/support/* directory among other scipts and `async: true` to mark that this test will run asynchronous with other tests. But be careful, if test writes data to database or in some sense changes some data then it should not run asyc.
Think of what should be tested. In this case let's test creating user with valid and invalid data. Some mockup data can be set via module attributes as constants, for example:
```
@valid_attributes %{name:    "John",
                    subname: "Doe",
                    email:   "doe@gmail.com",
                    job"     "engineer"
                   }
```
Ofcourse you don't have to use module attributes but it makes code cleaner. Next let's write test.
```  
test "user with valid attributes" do
  user = CompanyApiWeb.User.reg_changeset(%User{}, @valid_attributes)

  assert user.valid?
end
```
  In this test we try to create [changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html) by calling method *reg_changeset(changeset, params)* and then asserting for true value. If we run this test with `mix test test/company_api_web/models/user_test.exs`, test will fail ofcourse. First we dont even have User module, but we dont even have User table in database. Next we need to write a migration. `mix ecto.gen.migration create_user` generates migration in *priv/repo/migrations/*. There we define function for table creation in sugar elixir syntax which then translates into appropriate SQL query.
```
def change do
  create table(:users) do
    add :name, :varchar
    add :subname, :varchar
    add :email, :varchar
    add :job, :varchar
    add :password, :varchar

    timestamps()
  end
end
  ```
  Function *create* creates database table from struct returned by function *table*. For detail information about field type, options, and creating indexes read docs. By default surrogate key is generated for every table with name id and type integer if not defined otherwise.
Now we run command `mix ecto.migrate` which runs migration.
Next we need to create model, so create models directory in *lib/company_api_web/* and create user.ex file. 
Our model is used to represent data from database tables as it maps that data into Elixir structs.
```
defmodule CompanyApiWeb.User do
  use CompanyApiWeb, :model

  schema "users" do
    field :name, :string
    field :subname, :string
    field :email, :string
    field :password, :string
    field :job, :string
  end
  
  def reg_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :subname, :email, :job, :password])
    |> validate_required([:name, :subname, :email, :job])
    |> validate_format(:email, ~r/\S+@\S+\.\S+/)
  end
end
```
  On line 2, we use helper defined in company_api_web.ex which actually imports all necessary modules for creating models. If you open file you'll see that model is actually a function, same as controller, view, channel, router etc. (If there is no model function you can add it yourself).
Two important methods are schema (table <-> struct mapping) and *_changeset(changeset, params)*. Changeset functions are not necessary, but are Elixir's way of creating structs that modify database. We can define one for registration, login etc. All validation, constraint and association checking can be done before we even try inserting data into database. For more details check *Ecto.Changeset* docs.
If we now run test again, it should pass. Add as many test cases as you want and try to cover all edge cases. 
This should wrap creation of simple models. Adding association is going to be mention earlier. 

## Testing and writing controllers
  Testing controllers is equally important as testing models. We are going to test registration of new user and getting all registered users in a system. Again we create test, this time in *test/company_api_web/controllers/* with name user_controller_test.exs. With controller testing we're going to use conn_case.exs script. Another important thing about test that wasn't mention while testing models (cause we didn't need it) is setup block. 
```
setup do
  user =
    %User{}
    |> User.reg_changeset(@user)
    |> Repo.insert!

  conn =
    build_conn()
    |> put_req_header("accept", "application/json")

  %{conn: conn, user: user}
end
```
Setup block is called before invokation of each test case, and in this block we prepare data for tests. We can return data from block in a form of tuple or map. In this block we will insert one user into database and create connection struct which is mockup of connection. Again constants can be used to setup data. 
```
@valid_data %{name:    "Jim",
              subname: "Doe",
              email:   "doe@gmail.com",
              job:     "CEO"
             }

@user %{name:    "John",
        subname: "Doe",
        email:   "doe@gmail.com",
        job:     "engineer"
       }

@user_jane %{name:    "Jane",
             subname: "Doe",
             email:   "jane@gmail.com",
             job:     "architect"
            }
```
Now let's write test that sends request for creating new user. Server should process request, generate password, create new user, send email with generated password and return user as a json. That sounds like a lot, but we'll go slow. Pay attention that you should try to cover all 'paths' and edge cases. First let's test with valid data, and then with invalid data.
```
describe "tries to create and render" do
  test "user with valid data", %{conn: conn} do
    response =
      post(conn, user_path(conn, :create), user: @valid_data)
      |> json_response(201)

    assert Repo.get_by(User, name: "Jim")
    assert_delivered_email Email.create_mail(response["password"], response["email"])
  end

  test "user with invalid data", %{conn: conn} do
    response =
      post(conn, user_path(conn, :create), user: %{})
      |> json_response(422)

    assert response["errors"] != %{}
  end
end
```
Each test sends post request to certain path and then we check json response and assert value. Running this test with `mix test test/company_api_web/controller/user_controller_test.exs` will result in errors. We don't have *user_path* function which means that route isn't defined. Open *lib/company_api_web/router.ex*. We'll add scope "/api" which will go through :api pipeline. We can define routes as resources, individually or as nested routes. 
Define new resource like this:
`resources "/users", UserController, only: [:index, :create]`
With this, Phoenix creates routes which are mapped to index and create functions and handled by UserController. If you open console and type `mix phx.routes` you can see list of routes and there are *user_path* routes, one with verb GET and one with verb POST. Now if we run test again, this time we'll get another error, create function missing. Reason for this is that we don't have UserController.
Add user_controller.ex in *lib/company_api_web/controllers*. Now define new module:
```
defmodule CompanyApiWeb.UserController do
  use CompanyApiWeb, :controller
end
```
Next we need to create that create function. Create function must accept conn struct(and also return it) and params. Params is struct which carries all data supplied by browser. We can use one powerful feature of Elixir, pattern matching, to match just the data we need with our variables.
```
def create(conn, %{"user" => user_data}) do
  params = Map.put(user_data, "password", User.generate_password())
  case Repo.insert(User.reg_changeset(%User{}, params)) do
    {:ok, user} ->
      conn
      |> put_status(:created)
      |> render("create.json", user: user)
    {:error, user} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("error.json", user: user)
  end
end
```
In our tests we send through post method params *user: @valid_data*, and that data is going to be matched with *user_data*. In User model define *generate_password()* function, so we can generate random passwords for every new user.
```
 def generate_password do
    :crypto.strong_rand_bytes(@pass_length)
    |> Base.encode64
    |> binary_part(0, @pass_length)
  end
```
Set the length of a password as you wish. Since the user_data is a map we are going to put new generated password inside that map with key "password". 
Although Elixir has try/rescue blocks they are rarely used. Usually combination of case and pattern matching is used for error handling. Function insert(note that we won't use insert! function cause it raises exception) returns one of two tuples:
```
{:ok, Ecto.Schema.t}
{:error, Ecto.Changeset.t}
```
Based on returned tuple we send appropriate response. Since we're making JSON API, we should return data in json format. All data returned from controller is handled by appropriate view. If we run tests again, we are going to get another error. Last thing we need to do is to add view file. Create user_view.ex file in *lib/company_api_web/views/* and inside define new module and render methods.
```
defmodule CompanyApiWeb.UserView do
  use CompanyApiWeb, :view
  
  def render("create.json", %{user: user}) do
   render_one(user, CompanyApiWeb.UserView, "user.json")
  end
  
  def render("error.json", %{user: user}) do
    %{errors: translate_errors(user)}
  end
  
  def render("user.json", %{user: user}) do
    %{id: user.id, 
      name: user.name, 
      subname: user.subname, 
      password: user.password, 
      email: user.email, 
      job: user.job}
  end
  
  defp translate_errors(user) do
    Ecto.Changeset.traverse_errors(user, &translate_error/1)
  end
end
```
First render method is being called from controller, and in that method we call render_one to which we pass key, view module, and template name, so we can pattern match method. Now we return data which is going to be encoded into json. We didn't have to call render_one method, we could return json right away, but this is more convinient. 
Second render method renders errors provided by changeset struct in form of json. Built-in method *Ecto.Changeset.traverse_errors* extracts error strings from changeset.errors struct.
If we remove that one line which asserts that email has been sent, our tests will pass. This rounds up how we test and write controllers. Now you can test and write index method and add more test cases that covers more code.

## Email sending example
There are several email libraries in Elixir, but in this project we decided to use [Bamboo](https://github.com/thoughtbot/bamboo). After initial setup, its usage is fairly easy. 
Open *mix.exs* file and under deps function add following line:
`{:bamboo, "~> 0.8"}`
and then run following command:
`mix deps.get`
which will download dependency. After that add bamboo as extra_application in *application* function. In global config file add configuration for Bamboo:
```
config :company_api, CompanyApi.Mailer,
  adapter: Bamboo.LocalAdapter
```
Here we're using Bamboo.LocalAdapter but there are other adapters also. Now, create module CompanyApi.Mailer and following line:
`use Bamboo.Mailer, otp_app: :company_api`
Before using mailer we should define email struct. Add into models directory Email.ex file(Note that you should first write test then add file but we'll skip that now).
```
defmodule CompanyApiWeb.Email do
  import Bamboo.Email

  def create_mail(password, email) do
    new_email()
    |> to(email)
    |> from("company@gmail.com")
    |> subject("Generated password")
    |> html_body("<h1>Welcome to Chat</h1>")
    |> text_body("Welcome. This is your generated password #{password}. You can change it anytime.")
  end
end
```
Function *create_mail(password, email)* returns email struct which we will use for sending.
Before running tests we need to add configuration in *lib/config/test.exs*, same as before, only difference is in adapter which is now, Bamboo.TestAdapter.
Adding this `use Bamboo.Test` allows as to use function such as `assert_delivered_email` in our tests.
Now in UserController after successfull insert add next line:
```
Email.create_mail(user.password, user.email)
|> CompanyApi.Mailer.deliver_later
```
This is going to create email struct and send it in the background. For asynchronuos sending there is [Task](https://hexdocs.pm/elixir/Task.html) module.
If you wish to see sent mails, in *router.exs* add following:
```
if Mix.env == :dev do
  forward "/send_mails", Bamboo.EmailPreviewPlug
end
```
Now we can see delivered mails at *localhost:4000/sent_mails*.

##Authentication via Guardian
So far we've have shown how to write tests, migrations, models, controllers, views and routing. One more important thing is authenticating user. Library of choice here was [Guardian](https://github.com/ueberauth/guardian). It uses JWT (Json Web Token) as a method of authentication and we can authenticate Phoenix services and also channels. Great stuff. 
First add dependency in mix.exs file `{:guardian, "~> 1.0-beta"}` and run `mix deps.get`. In Guardian docs there is detail explanation how to setup basic configuration, but we're going to go step by step here. 
Open */config/config.exs* and add following:
```
config :company_api, CompanyApi.Guardian,
  issuer: "CompanyApi",
  secret_key: "QDG1lCBdCdjwF49UniOpbxgUINhdyvQDcFQUQam+65O4f9DgWRe09BYMEEDU1i9X",
  verify_issuer: true
```
Note that CompanyApi.Guardian is going to be module that we're going to create. You don't have to call it Guardian, maybe it's little redundant. Anyway, next thing is secret_key that has to be generated. This is example of one secret key, and it can be generated by running 
`mix guardian.gen.secret`.
Create CompanyApi.Guardian module in *lib/company_api/*.
```
defmodule CompanyApi.Guardian do
  use Guardian, otp_app: :company_api

  alias CompanyApi.Repo
  alias CompanyApiWeb.User

  def subject_for_token(user = %User{}, _claims) do
    {:ok, "User:#{user.id}"}
  end

  def subject_for_token(_) do
    {:error, "Unknown type"}
  end

  def resource_from_claims(claims) do
    id = Enum.at(String.split(claims["sub"], ":"), 1)
    case Repo.get(User, String.to_integer(id)) do
      nil  ->
        {:error, "Unknown type"}
      user ->
        {:ok, user}
    end
  end
end
```
This module is going to be used when token is being created. We've put user id as a subject for token, in that way we can always get user from database. This may be the most convinient way, but it's not the only way.
Next thing we're going to do is to set up guardian pipeline. Using Guardian with plugs is easy. Open *lib/company_api_web/router.ex* and add new pipeline:
```
pipeline :auth do
    plug Guardian.Plug.Pipeline, module: CompanyApi.Guardian,
                           error_handler: CompanyApi.GuardianErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, ensure: true
  end
```
This pipeline can be defined directly in router.ex file, or can be defined in separate module, but still needs to be referenced here. When user tries to call some service his request is going to pass through pipeline. Note that this pipeline is specifically for **JSON API**. Okey, first we define that we're using plug pipeline and reference implementation module and module that is going to handle auth errors(we're going to create it). Next plug verifies that token is in request header, plug EnsureAuthenticated ensures that valid JWT token was provided and last plug loads resource by calling function *resource_from_claims(claims)* specified in CompanyApi.Guardian module. 
Since we're missing auth_error handling module add it in *lib/company_api*.
```
defmodule CompanyApi.GuardianErrorHandler do
  def auth_error(conn, {_type, reason}, _opts) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, Poison.encode!(%{message: to_string(reason)}))
  end
end
```
[Poison](https://github.com/devinus/poison) is Elixir JSON library. Just add dependency in mix.exs `{:poison, "~> 3.1"}`.
We've set up everything for Guardian and now it's time to write SessionController and handle login and logout. First we have to write tests. Create *session_controller_test.exs*. We're going to test user login and make it pass. 
We've already wrote tests for UserController so you know how to set up this one also. 
```
  test "login as user", %{conn: conn, user: user} do
    user_credentials = %{email: user.email, password: user.password}
    response =
      post(conn, session_path(conn, :create), creds: user_credentials)
      |> json_response(200)

    expected = %{
      "id"        => user.id,
      "name"      => user.name,
      "subname"   => user.subname,
      "password"  => user.password,
      "email"     => user.email,
      "job"       => user.job
    }

    assert response["data"]["user"]   == expected
    refute response["data"]["token"]  == nil
    refute response["data"]["expire"] == nil
  end
```
We're going to try to login with valid credentials and we expect to get as a response user, token and expire value. If we run this test it is going to fail. We don't have session_path route. Open router.ex file and in our "/api" scope add new route:
`post "/login", SessionController, :create`
We've put this route in "/api" scope becase our user doesn't need to get authenticated while he's trying to login. If we run test again, this time it is going to fail becase there is no create function. 
Let's add SessionController now and write login function.
```
 def create(conn, %{"creds" => params}) do
    new_params = Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)
    case User.check_registration(new_params) do
      {:ok, user} ->
        new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)
        token    = Guardian.Plug.current_token(new_conn)
        claims   = Guardian.Plug.current_claims(new_conn)
        expire   = Map.get(claims, "exp")

        new_conn
        |> put_resp_header("authorization", "Bearer #{token}")
        |> put_status(:ok)
        |> render("login.json", user: user, token: token, exp: expire)
      {:error, reason} ->
        conn
        |> put_status(401)
        |> render("error.json", message: reason)
    end
  end
```
First line creates new map as a result with keys as atoms. Function *check_registration(new_params)* checks if user with given credentials exist in database. If user exists we sign him in, create new token and expire date. After that we set response header, status and render user. For rendering we need to create session_view.ex in *lib/company_api_web/views*.
```
defmodule CompanyApiWeb.SessionView do
  use CompanyApiWeb, :view

  def render("login.json", %{user: user, token: token, exp: expire})  do
    %{
      data: %{
        user:   render_one(user, CompanyApiWeb.UserView, "user.json"),
        token:  token,
        expire: expire
      }
    }
  end
  
  def render("error.json", %{message: reason}) do
    %{data: reason}
  end
end
```
Now test should pass. Ofcourse more tests should be added, but that's up to you. Logout is fairly simple, `Guardian.revoke(CompanyApi.Guardian, token)` deletes token from header and that is all we need to do. With APIs there is no really logout, but this will work.
Before adding new route for logging out, we need to define "new scope". 
Actually this is going to be the same "/api" scope again, but it will go through two pipelines now: `pipe_through [:api, :auth]`. 
Why are we doing this? Every new route that needs to be authenticated will be places inside of this new scope. Also if we want to logout, we need to be authenticated first. With this we've covered authenticating with Guardian. Later socket authentication is going to be mentioned, and it's even easier.


















