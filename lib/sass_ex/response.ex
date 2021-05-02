defmodule SassEx.Response do
  @moduledoc """
  Contains the response from compiling the Sass file
  """
  defstruct [:css, :source_map]

  @type t :: %__MODULE__{
          css: String.t(),
          source_map: String.t()
        }
end
