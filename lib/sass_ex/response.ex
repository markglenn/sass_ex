defmodule SassEx.Response do
  defstruct [:css, :source_map]

  @type t :: %__MODULE__{
          css: String.t(),
          source_map: String.t()
        }
end
