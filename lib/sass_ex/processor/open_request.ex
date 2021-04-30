defmodule SassEx.Processor.OpenRequest do
  @moduledoc """
  Contains information on an open request for compiling a SCSS document
  """

  defstruct [:id, :pid]

  @type t :: %__MODULE__{
          id: integer,
          pid: pid()
        }
end
