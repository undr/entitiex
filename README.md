# Entitiex

Entitiex is an Elixir presenter library used to transform data structures. This is useful when the desired representation doesn't match the schema defined within the domain model.  I'd say it's a kind of `Grape::Entity` ported from the Ruby world.


Inspired by [`grape-entity`](https://github.com/ruby-grape/grape-entity) gem.

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

### Defining Entities

Entities should use `Entitiex.Entity`, it gives convenient DSL to define a scheme of an entity.

```elixir
defmodule UserEntity do
  use Entitiex.Entity
end
```

#### Define Exposures

Define a list of fields that will always be exposed.

```elixir
expose :name, as: :alias
```

The field lookup takes several steps:

- first try `UserEntity.name(user)`
- next try `UserEntity.name(user, :alias)`
- next try `User.name(user)`
- next try `Map.fetch(user, :name)`


For example, we have a struct:

```elixir
defmodule User do
  defstruct [:id, :name, :phone]

  def names(struct) do
    String.split(struct.name)
  end
end
```

and we want to expose these fields:

```elixir
expose [:id, :name]
expose :phone
```

All values will be given using the last step: `Map.fetch/2`. However, when we will expose a virtual field, which doesn't exist in a struct, then an entity will look up a value using a function, defined in the entity or in the module of the struct.

```elixir
expose :names
```

It will use `User.names(user)` to find value.

```elixir
expose :country_phone_code

def country_phone_code(struct) do
  Phones.country_code(struct.phone)
end
```

And this will use `UserEntity.country_phone_code(user)`.

If the exposed field has an alias, you can also catch it inside the defined function:

```elixir
expose :amount
expose :amount, as: :amount_in_cents

def amount(struct, :amount),
  do: struct.amount / 100
def amount(struct, :amount_in_cents),
  do: struct.amount
```

```elixir
%{
  amount: 109.99,
  amount_in_cents: 10999
}
```

As you can notice, it's possible to pass options into the `expose` macro — full list of options listed below.

- `:as` - Expose under a different name.
- `:format` - Apply formatters before exposing a value.
- `:format_key` - Apply formatters to key before exposing a value.
- `:using` - Use another entity to represent a map or collection.
- `:if` - Conditional exposure. Use `:if` to give condition functions, and then the field will only be exposed if each function returns `true`.
- `:expose_nil` - Use this key to specify how `nil` values should be represented.
- `:merge` - Merge nested entity into the root map.

#### Formatting Values And Keys

```elixir
expose :name, format: &Utils.capitalize/1
expose :amount, format: [:to_s, &Money.format/1]
```

```elixir
%{
  name: "Jon Stark",
  amount: "$109.99"
}
```

```elixir
expose :full_name, format_key: :lcamelize
expose :amount, format_key: [:to_s, &String.reverse/1]
```

```elixir
%{
  "fullName" => "jon stark",
  "tnuoma" => 10999
}
```

It's also possible to set key formatters for the whole entity and they will be applied to all keys in the resulting map.

```elixir
format_keys :lcamelize

expose :some_long_field
expose :another_one_long_field
```

```elixir
%{
  "someLongField" => "...",
  "anotherOneLongField" => "..."
}
```

Entitiex provides a list of default formatters and you can reffer to them using a symbol. Default formatters are `:to_s`, `:to_atom`, `:upcase`, `:downcase`, `:camelize` and `:lcamelize`.

#### Using Nested Entities

There are two ways to work with nested structures in a source map. You can reuse your entities' modules using `:using` option.

```elixir
expose :address, using: AddressEntity
```

Or you can dynamically create an entity which should represent nested map using `inline` macro.

```elixir
inline :address do
  expose :country
  expose :city
  expose :lines
end
```

There is also a way to create a nested structure in a resulting map from a flat source map.

```elixir
expose :name
nesting :company do
  expose :company_name, as: :name
  expose :company_address, as: :address, using: AddressEntity
end
```

Suppose we have such struct:

```elixir
defstruct [name: nil, company_name: nil, company_address: %Address{}]
```

So, the resulting map will be something like this:

```elixir
%{
  name: "...",
  company: %{
    name: "...",
    address: %{...}
  }
}
```

The `nesting` and `inline` macros can also accept options, the same as `expose` macro.

```elixir
inline :address, if: :include_address? do
  expose :country
  expose :city
  expose :lines
end
```

#### Conditional Exposure

Use `:if` to expose fields conditionally. It accepts only functions in the shape of `Module.function/arity` or atoms. Atoms will be compiled to normalized form (`Entity.atom/1`, `Entity.atom/2`) before compile time.

Also, it accepts an array of mentioned before types. An array of functions will be executed as a chain. All functions will be executed in the same order as they are listed in the array. All results will be aggregated.

```elixir
expose :charges, using: ChargesEntity, if: :billed?
expose :activity_state, if: &User.active?/1
expose :activity_history, if: [&User.active?/1, :can_see_history?]
```

#### Expose `nil` Values

By default, exposures that contain `nil` values will be represented in the resulting map as `nil`. You can override this behaviour using `:expose_nil` option. `nil` values won't be exposed when this option is set to `false`.

```elixir
expose :will_be_exposed_when_nil
expose :wont_be_exposed_when_nil, expose_nil: false
```

#### Merge Fields

Use :merge option to merge fields into the root map:

```elixir
inline :company, merge: true do
  expose :name, as: :company_name
  expose :email, as: :company_name
end
```

This will return something like:

```elixir
%{
  company_name: "Super LLC",
  company_email: "superhero@gmail.com"
}
```

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

UserEntity.represent([user], root: :data, extra: [meta: %{additional: "data"}])
# => %{"data" => [%{"id" => "1", ...}], "meta" => %{"additional" => "data"}}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/entitiex](https://hexdocs.pm/entitiex).
