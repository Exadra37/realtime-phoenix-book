defmodule HelloSockets.Pipeline.Producer do
  use GenStage

  def start_link(opts) do
    {[name: name], opts} = Keyword.split(opts, [:name])
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def init(_opts) do
    {:producer, :unused, buffer_size: 10_000}
  end

  # GenStage buffer will drop events after reaches the configure limit,
  # therefore care needs to be taken to not produce more events then what
  # consumers can process.
  #
  # @link https://elixirforum.com/t/genstage-producer-discarding-events/1943/3?u=exadra37
  # > ...without actually caring if there is a consumer ready to process your
  # > events. You need to make sure to only emit events after you receive demand
  # > in handle_demand.
  #
  # Read more at official docs:
  # @link https://hexdocs.pm/gen_stage/GenStage.html#module-buffering-demand
  # > In case consumers send demand and the producer is not yet ready to fill in
  # > the demand, producers must buffer the demand until data arrives.
  def handle_demand(_demand, state) do
    # This reply means that we don't care about the demand.
    {:noreply, [], state}
  end

  def push(item = %{}) do
    GenStage.cast(__MODULE__, {:notify, item})
  end

  def handle_cast({:notify, item}, state) do
    {:noreply, [%{item: item}], state}
  end

end
