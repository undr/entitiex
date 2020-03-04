defmodule Entitiex.Types do
  @type exposure :: %Entitiex.Exposure{
    key: key(),
    attribute: attr(),
    conditions: [normal_func()],
    entity: module(),
    handlers: [handler()],
    opts: exp_opts()
  }
  @type runtime_opts :: [runtime_opt()]
  @type runtime_opt :: {:root, key()} | {:extra, extra()} | {:context, extra()}
  @type exp_opts :: [exp_opt()]
  @type exp_opt ::
    {:format, normal_func()} |
    {:format_key, normal_func()} |
    {:nested, module()} |
    {:merge, boolean()} |
    {:using, module()} |
    {:if, normal_func()} |
    {:as, atom()}

  @type key :: attr()
  @type attr :: String.t() | atom()
  @type handlers :: [handler()]
  @type handler :: EntityHandler | FormattedHandler | DefaultHandler
  @type func :: fun() | mfa() | {module(), atom()} | atom()
  @type normal_func :: fun() | mfa()
  @type extra :: map() | Keyword.t()
  @type value_tuple :: {:merge, any()} | {:put, any()} | :skip
  @type formatter :: fun() | atom()
end
