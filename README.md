# Entitiex

Entitiex is an Elixir presenter library used to transform data structures. This is useful when the desired representation doesn't match the schema defined within the domain model.  I'd say it's a kind of `Grape::Entity` ported from the Ruby world.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `entitiex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:entitiex, "~> 0.1.0"}
  ]
end
```

## Usage

## Examples

```elixir
defmodule User do
  defstruct [:id, :first_name, :last_name, :title, :locked, :roles, :company]

  def addresses(_struct) do
    [
      %Address{id: 1, type: :home, country: "Russia", city: "Moscow", line: "7, Parkovaya st., Veshki, Altufievskoe haiway"},
      %Address{id: 2, type: :work, country: "Thailand", city: "Phuket", line: "272, Land and House, Chao Fah Rd., Chalong"}
    ]
  end

  def contacts(_struct) do
    [
      %Contact{id: 2, type: :phone, line: "+70000000000"},
      %Contact{id: 3, type: :email, line: "superhero@gmail.com"}
    ]
  end
end

defmodule Company do
  defstruct [:id, :name, :active]
end

defmodule Address do
  defstruct [:id, :type, :country, :city, :line]
end

defmodule Contact do
  defstruct [:id, :type, :line]
end

defmodule UserEntity do
  use Entitiex.Enity

  format_keys :lcamelize

  expose :id, format: :to_s
  expose :locked, as: :is_locked
  expose :roles, format: :to_s
  expose :full_name

  nesting :name do
    expose :first_name, as: :first
    expose :last_name, as: :last
  end

  inline :company, if: :active_company? do
    expose :id, format: :to_s
    expose :name, format: [:to_s, &String.upcase/1]
  end

  expose :adresses, using: AddressEntity
  expose :contacts, using: ContactEntity

  def active_company?(_struct, company) do
    company.active
  end

  def full_name(struct) do
    "#{struct.first_name} #{struct.last_name}"
  end
end

defmodule AddressEntity do
  use Entitiex.Enity

  format_keys :lcamelize

  expose [:id, :type], format: :to_s
  expose :country, as: :country_iso_code
  expose :city
  expose :line

  def country(struct) do
    Countries.iso_code(struct.country)
  end
end

defmodule ContactEntity do
  use Entitiex.Enity

  format_keys :lcamelize

  expose [:id, :type], format: :to_s
  expose :line
end
```

```elixir
UserEntity.represent(user)
```

```elixir
%{
  "id" => "1",
  "isLocked" => true,
  "roles" => ["member", "admin"],
  "fullName" => "Super Hero",
  "name" => %{
    "first" => "Super",
    "last" => "Hero"
  },
  "company" => %{
    "id" => "12",
    "name" => "SUPER LCC"
  },
  "addresses" => [
    %{"id" => "1", "type" => "home", "countryIsoCode" => "RU", "city" => "Moscow", "line" => "7, Parkovaya st., Veshki, Altufievskoe haiway"},
    %{"id" => "2", "type" => "work", "countryIsoCode" => "TH", "city" => "Phuket", "line" => "272, Land and House, Chao Fah Rd., Chalong"}
  ],
  "contacts" => [
    %{"id" => "2", "type" => "phone", "line" => "+70000000000"},
    %{"id" => "3", "type" => "email", "line" => "superhero@gmail.com"}
  ]
}
```

```elixir
UserEntity.represent(user, root: :data, extra: [meta: %{additional: "data"}])
# => %{"data" => %{"id" => "1", ...}, "meta" => %{"additional" => "data"}}
```

```elixir
UserEntity.represent([user], root: :data, extra: [meta: %{additional: "data"}])
# => %{"data" => [%{"id" => "1", ...}], "meta" => %{"additional" => "data"}}
```

---

Inspired by [`grape-entity`](https://github.com/ruby-grape/grape-entity) gem.

---

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/entitiex](https://hexdocs.pm/entitiex).
