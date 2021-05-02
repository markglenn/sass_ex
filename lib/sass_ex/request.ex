defmodule SassEx.Request do
  @moduledoc false

  defstruct [:id, :pid, :importers]

  @type t :: %__MODULE__{
          id: integer,
          pid: GenServer.from(),
          importers: [SassEx.Processor.importer_t()]
        }
end
