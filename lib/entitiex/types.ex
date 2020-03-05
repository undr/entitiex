defmodule Entitiex.Types do
  @type exposure :: %Entitiex.Exposure{
    key: key(),
    attribute: attr(),
    conditions: normal_funcs(),
    entity: module(),
    handlers: handlers(),
    opts: normal_exp_opts()
  }

  @type runtime_opts :: [runtime_opt()]
  @type runtime_opt :: {:root, key()} | {:extra, extra()} | {:context, extra()}
  @type exp_opts :: [exp_opt()]
  @type exp_opt ::
    {:format, funcs()} |
    {:format_key, funcs()} |
    {:nested, module()} |
    {:merge, boolean()} |
    {:using, module()} |
    {:if, funcs()} |
    {:as, atom()}

  @type normal_exp_opts :: [normal_exp_opt()]
  @type normal_exp_opt ::
    {:format, normal_funcs()} |
    {:format_key, normal_funcs()} |
    {:merge, boolean()} |
    {:using, module()} |
    {:if, normal_funcs()} |
    {:as, atom()}

  @type key :: attr()
  @type attr :: String.t() | atom()
  @type handlers :: [handler()]
  @type handler :: EntityHandler | FormattedHandler | DefaultHandler
  @type func :: fun() | atom()
  @type funcs :: [func] | func()
  @type normal_func :: fun()
  @type normal_funcs :: [normal_func()]
  @type extra :: map() | Keyword.t()
  @type value_tuple :: {:merge, any()} | {:put, any()} | :skip
end
