defmodule Skillchecker.Cldr do
  @moduledoc false

  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.Unit, Cldr.List]
end