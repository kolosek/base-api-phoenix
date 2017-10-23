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
We create our application by running
`mix phx.new company_api`
This tells mix to create new Phenix app named >company_api. After running this instruction mix will create application structure:
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
All configurations are placed in >company_api/config/config.exs file. 

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
First in directory *test/companyapiweb/* create models directory and then create user_test.exs. After that create a module, 
```
defmodule CompanyApiWeb.UserTest do
    use CompanyApi.DataCase, async: true
end
```
On second line, we use macro *use* to inject some external code, in this case data_case.exs script that is placed in >test/support/ directory among other scipts and `async: true` to mark that this test will run asynchronous with other tests. But be careful, if test writes data to database or in some sense changes some data then it should not run asyc.
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
In this test we try to create [changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html) by calling method *regchangeset(changeset, params)* and then asserting for true value. If we run this test with `mix test test/company_api_web/models/user_test.exs`, test will fail ofcourse. First we dont even have User module, but we dont even have User table in database. Next we need to write a migration.
`mix ecto.gen.migration create_user` generates migration in *priv/repo/migrations/*. There we define function for table creation in sugar elixir syntax which then translates into appropriate SQL query.
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
Setup block is called before invoking each of test cases, and in this block we prepare data for tests. We can return data from block in a form of tuple or map. In this block we will insert one user into database and create connection struct which is mockup of connection.




















