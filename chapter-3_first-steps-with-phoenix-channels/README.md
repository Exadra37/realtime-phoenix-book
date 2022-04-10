# CHAPTER 3 - FIRST STEPS WITH PHOENIX CHANNELS

You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## First Steps with Phoenix Channels

> Real-time applications exist at the intersection of a communication layer and business logic that satisfies the needs of users.

> Phoenix. Phoenix Channels are the most powerful real-time abstraction that 
> currently exists in the Elixir community, and we will be exploring their 
> basics in order to develop a real-time foundational toolkit.

### What are Phoenix Channels?

> One of the components of Phoenix is Channels, a way to effectively write
> bidirectional real-time web applications. They allow us to write our 
> application code without worrying about details such as “how is the connection
> set up and maintained?” or “how can I scale the number of connections easily?”

> Channels work, at a high level, by allowing clients to connect to the web
> server and subscribe to various topics. The client then sends and receives
> messages over its subscribed topics. A client subscribes to as many topics
> as desired on a single connection, which reduces the number of expensive
> connections.

> Once a client is connected to a Channel, it sends data to the server or 
> receives data from the server through the Channel. The flow, from a client's 
> perspective, works in this simple way:
> 1. The client subscribes to topics on the server via the Phoenix Channel
> 2. The client sends and receives data to/from the server via the same Phoenix Channel

> Channels are built using strong OTP application design. Every layer that makes
> up Channels is represented by separated OTP processes that allow for fault 
>tolerance and simpler application design. You will benefit from this foundation 
> without needing to worry too heavily about it. Even though OTP concepts are 
> seen in nearly every Elixir application we write, the details of Channels' OTP 
> design are largely hidden from our immediate view. This allows even Elixir 
> beginners to use Channels to write performant and maintainable applications.

> One of the benefits of Channels is that they are transport agnostic. In the
> last chapter we covered the real-time communication layer, with a focus on
> WebSockets, where you learned that our application is powered by a real-time
> layer but isn't defined by it. This means that, in an ideal world, we should
> have a way to easily switch out the real-time layer without changing 
> application logic. A transport-agnostic tool, like Channels, makes this a 
> possibility because Channels draw clear seams across different parts of the 
> system.

### Understanding Channel Structure

> A client connects to the server via transport mechanism such as a WebSocket,
> by connecting directly to an OTP process that manages the connection. This
> process delegates certain operations, such as whether to accept or reject the
> connection request, to our application code that implements the Phoenix.Socket
> behaviour.

> The module that uses Phoenix.Socket has the ability to route topics that the
> client requests to a provided Phoenix.Channel implementation module. The
> Channel module starts up a separate process for each different topic that the
> user connects to. Channels, like transport processes, are never shared between
> different connections.

> Phoenix.PubSub is used to route messages to and from Channels. You can see
> in the diagram that a distinction is made between local and remote PubSub
> processes. Messages are broadcast through the PubSub process and are sent
> to both the local node and remote nodes. For now, just know that PubSub
> allows a cluster of nodes to work with Channels.

### Sockets

> Sockets form the backbone of real-time communication in Phoenix. A Socket
> is a module that implements the Phoenix.Socket.Transport behaviour, but we'll be
> using a specific implementation called Phoenix.Socket . You'll most likely be using
> Phoenix.Socket in your application because it implements both WebSockets and
> long polling in a way that follows best practices. (If you ever need a custom
> transport layer, which is rare, then you do have the ability to implement your
> own Socket.Transport .)

### Channels

> Channels are the real-time entry points to our application’s logic and where
> most of an application’s request handling code lives. A Channel has several
> different responsibilities to enable real-time applications:
> * Accept or reject a request to join.
> * Handle messages from the client.
> * Handle messages from the PubSub.
> * Push messages to the client.

> The distinction between Channels and Sockets may not be obvious at a glance.
> A Socket's responsibilities involve connection handling and routing of requests
> to the correct Channel. A Channel's responsibilities involve handling requests
> from a client and sending data to a client. In this way, a Channel is similar
> to a Controller in the MVC (Model-View-Controller) design pattern.

> It has become popular in recent years to use the mantra “skinny controllers”
> to indicate that we don't want business logic in our controllers. This same
> mantra can be applied to Channels; we should strive to keep application
> logic in our application's core and not have it implemented in our Channels.
> The exception to this is that logic needed for real-time communication 
> customization is best implemented at the Channel level

### Implement Our First Channel

The channel minimal implementation:

```elixir
defmodule HelloSocketsWeb.PingChannel do

  use HelloSocketsWeb, :channel

  @impl true
  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end
  
end
```

> `use` is a special keyword in Elixir that invokes the `__using__` macro. In 
> the case of Phoenix.Channel, it includes the bulk of the code to make the 
> Channel functional.
> We allow any connection to this Channel to succeed by not implementing any
> join logic. This is acceptable for topics that we want to be fully public. 
> It is not


> `handle_in/3` receives an event, payload, and the state of the current Socket. We
> only allow the ping event to be processed; any other event will be an error. We
> are able to do several things when we receive a message:
> * Reply to the message by returning {:reply, {:ok, map()}, Phoenix.Socket} . The
> payload must be a map.
> * Do not reply to the message by returning {:noreply, Phoenix.Socket} .
> * Disconnect the Channel by returning {:stop, reason, Phoenix.Socket} .
