defmodule SassEx.Processor.OpenRequest do
  @moduledoc """
  Contains information on an open request for compiling a SCSS document
  """

  defstruct [:id, :pid, :importers]

  @type importer_t :: Module | Struct

  @type t :: %__MODULE__{
          id: integer,
          pid: GenServer.from(),
          importers: [importer_t()]
        }
end
