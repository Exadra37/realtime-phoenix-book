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

### Handle Channel Errors

> A major difference between a traditional web Controller and a Channel is that
> the Channel is long-lived. In a perfect world, a Channel will live for the entire
> life of the connection without being interrupted. But we don't live in a perfect
> world, and disconnections are going to occur in our application. They may
> occur because of a bug in our application causing a crash or because the
> client's internet connection is not stable.

> This reinforces the important part of the Channel structure that OTP enables:
> fault tolerance. An error that happens in a single Channel should not affect
> any other Channels and should not affect the Socket. An error that happens
> in the Socket, however, will affect all Channels that exist under the Socket
> because they are dependent on the Socket working correctly.

> It is up to the client to respond to the "phx_error" response by ensuring that it
> rejoins the Channel and responds to the connection drop by reconnecting.
> The official JavaScript client handles all of this for you so you don't need to
> worry about the orchestration of the connection. Any non-official clients will
> need to handle this properly, however, or they could end up being connected
> to the Socket but not connected to a Channel.

### Topics

> Topics are string identifiers used for connecting to the correct Channel when
> the "phx_join" message is received by the Socket.

> A topic can be any string, but it is best practice to use a "topic:subtopic" format
> for the topic name. This convention allows us to have a single Socket module
> with different types of Channels associated to it. This is because channel/3 can
> accept a wildcard splat operator as the final part of the string.

> It's possible to use the topic of "*" to allow any topic to route to the Channel.
> Any routing is allowed as long as the * character is at the end of the topic
> string. Try adding a character after "*" in our example above to see what
> happens by changing "ping:*" to "ping:*a" . Luckily for us, Phoenix has protections
> in place that cause an error at compile time

> It is useful to note that topic routes must end with a wildcard, but they could
> contain multiple pieces of dynamic data. This is due to limitations in pattern
> matching when the wildcard isn't at the end.

> Dynamic topic names are very useful. I have implemented them to give stable
> identifiers to private Channels based on multiple pieces of data. For example,
> the format "notifications:t-1:u-2" could be used to identify a notifications 
> topic for user 2 on team 1. This allows notifications to be pushed from any 
> part of the system that is capable of providing a user and team ID. It also 
> prevents different users from receiving each other's private notifications.

### Selecting a Topic Name

> A carefully selected topic name is important for the scalability and behavior
> of an application. For instance, a public Channel providing inventory updates
> to an e-commerce storefront could be implemented in a variety of ways:
> * "inventory" - This topic does not delineate between different SKUs
> * "inventory:*" - This topic delineates between different item SKUs with a
> wildcard

> If an overly broad topic is selected, such as "inventory" , then an inventory change
> to a SKU is broadcast to every connected client, even if they are not viewing
> the item. A narrower topic such as "inventory:*" would lead to more connected
> topics (1 per viewed item), but means that outgoing data could be held back
> from clients that aren't viewing a particular SKU.
> In this example, you would select a solution based on your business needs and
> tolerances.

> The battle between scalability of performance and maintenance is a constant
> one; the best solution is often dependent on decisions specific to a business.

### PubSub

> Phoenix.PubSub (publisher/subscriber) powers topic subscription and message
> broadcasting in our real-time application. Channels use PubSub internally,
> so we will rarely interact with it directly. However, it's useful to understand
> PubSub because we'll need to configure it properly for our application to
> ensure performance and communication availability.

> PubSub is linked between a local node and all connected remote nodes. This
> allows PubSub to broadcast messages across the entire cluster. Remote message
> broadcasting is important when we have a situation where a client is connected
> to node A of our cluster, but a message originates on node B of our cluster.
> PubSub handles this for us out-of-the-box, but we do need to make sure that
> the nodes have a way to talk to each other. PubSub ships with a pg2 adapter
> out-of-the-box. There is also a Redis PubSub adapter that allows for using
> PubSub without having nodes clustered together.

### Send and Receive Messages

#### Phoenix Message Structure

> Phoenix Channels use a simple message protocol to represent all messages
> to and from a client. The contents of the Message allow clients to keep track
> of the request and reply flow, which is important because multiple asyn-
> chronous requests can be issued to a single Channel.

Phoenix message signature:

```elixir
[
  Join ref,
  Message ref,
  topic,
  event,payload
]
```

For example:

```elixir
[
  "1",
  "1",
  "ping"
  "phx_join",
  {}
]

```

> Let's break down each of these fields and their use in the Channel flow:
> * Join Ref—A unique string that matches what the client provided when it
> connected to the Channel. This helps prevent duplicate Channel subscrip-
> tions from the client. In practice, this is a number that is incremented
> each time a Channel is joined.
> * Message Ref—A unique string provided by the client on every message.
> This allows a reply to be sent in response to a client message. In practice,
> this is a number which is incremented each time a client sends a message.
> * Topic—The topic of the Channel.
> * Event—A string identifying the message. The Channel implementation
> can use pattern matching to handle different events easily.
> * Payload—A JSON encoded map (string) that contains the data contents
> of the message. The Channel implementation can use pattern matching
> on the decoded map to handle different cases for an event.

> Some pieces of the message format are optional and can be null depending
> on the situation. For example, we saw that the ref strings were both null when
> we used broadcast to send a message to our client. This happens because the
> information is owned by the client, so the server cannot provide it when
> pushing data that isn't in reply to an original message.

> The official Phoenix Channel clients send a join ref and message ref with every
> message. The Channel sends the same topic, join ref, and message ref to a
> client when a successful reply is generated. This allows the client to associate
> the incoming message to a message that had been sent to the server, causing
> it to be recognized as a reply.

### Receiving Messages from a Client

> When a client sends a message to a Channel, the transport process receives
> the message and delegates it to the Socket’s handle_in/2 callback. The Socket
> sends the decoded Message struct to the correct Channel process and handles
> any errors such as a mismatched topic. The Phoenix.Channel.Server process han-
> dles the sent message by delegating to the associated Channel implementation's
> handle_in/3 callback. This happens transparently to us, meaning that we only
> need to be concerned with the client sending a message and our Channel's
> handle_in/3 callback processing the message.
> 
> A benefit to this flow being heavily process-based is that the Socket will not
> block while waiting for the Channel to process the message. This allows us
> to have many Channels on a single Socket while still maintaining the high
> performance of our system.

> You'll notice that the payload uses strings and not atoms. Atoms are not
> garbage collected by the BEAM, so Phoenix does not provide user-submitted
> data as atoms. You can use either atoms or string when creating a response
> payload.

#### Using Pattern Matching to Craft Powerful Functions

> The payload of the message is more flexible than the event name when
> designing the message handling of a system. It can be used to provide complex
> payloads (any JSON is valid) with values of types other than string. The event
> name, on the other hand, must always be a string and cannot represent
> complex data structures.

#### Other Response Types

> There are other ways that we can handle an incoming event rather than
replying to the client. Let's look at two different ways to respond: doing
nothing or stopping the Channel.

> Our `:noreply` response is the simplest here, as we simply do nothing and don't
> inform the client of a response. The `:shutdown message` is slightly more complex
> because we must provide an exit reason and an optional response. We are pro-
> viding an `:ok` and map tuple as our response, but we can omit this argument for
> an equally correct response. The exit reason uses standard `GenServer.terminate/2`
> reasons. You most likely want to use :normal or :shutdown with this feature as it
> properly closes the Channel with a phx_close event.

#### Pushing Messages to a Client

> We have seen an example of how PubSub is used to broadcast from our Endpoint
> module. We were able to push a message to our connected topic without
> writing any Channel handler code. This is the default behavior of Channels:
> any message sent to their topic is broadcast directly to the connected client.
> We can customize this behavior, however, by intercepting any outgoing mes-
> sages and deciding how to handle them.

>It is best practice to not write an intercepted event if you do not need to 
> customize the payload, because each pushed message will be encoded by itself,
>up to once per subscribed Channel, instead of a single push to all subscribed
>Channels. This will decrease performance in a system with a lot of subscribers.

> **Intercepting Events for Metrics**
> While it is best practice to not intercept events that are not changed, because of the
> decreased performance, it can be useful for tasks such as collecting metrics about
> every push. You would still incur the interception penalty discussed in this section,
> but the benefit of metrics outweighs that.
> In [PushEx](https://hex.pm/packages/push_ex), a an implementation of Channels for pushing data to clients, I use inter-
> ception to capture a delivery metric for every message to every client. Capturing
> messages at this level allows me to keep track of the number of milliseconds that a
> message stays in the system for each connected client. The system must keep this
> metric low to ensure that users are getting their data as quickly as possible.

### Channel Clients

> Any networked device can be used to connect to Channels. Languages that
have a WebSocket or HTTP client (for long polling) are easiest to get started
with.

> There are official and unofficial clients that work out-of-the-box with
> Channels, and these clients can certainly make the task easier for us. A [list
> of client libraries](https://hexdocs.pm/phoenix/channels.html#client-libraries) is maintained in the Phoenix Channel documentation.

#### Official JavaScript Client

> Any Channel client has a few key responsibilities that should be followed, in
> order for all behavior to work as expected:
> Connect to the server and maintain the connection by using a heartbeat.
> * Join the requested topics.
> * Push messages to a topic and optionally handle responses.
> * Receive messages from a topic.
> * Handle disconnection and other errors gracefully; try to maintain a connection whenever possible.

#### Sending Messages with the JavaScript Client

> We are logging that the ping is sent before our joined reply comes in. This
> highlights an important aspect of the JavaScript client: if the client hasn't
> connected to the Channel yet, the message will be buffered in memory and
> sent as soon as the Channel is connected. It is stored in a short-lived (5-sec-
> ond) buffer so that it doesn't immediately fail. This behavior is useful if our
> Channel ever becomes disconnected due to a client network problem, because
> several seconds of reconnection are available before the message is handled
> as an error.

> If you only want to send a message when the topic is connected, it is possible
> to do so. In that case you would move the push function inside of the join "ok"
> handler callback.

> Sometimes messages are not handled correctly by the server. For instance,
> it could be under heavy load or we could have a coding bug in our Channel
> handlers. For this reason, it's a best practice to have error and timeout 
> handlers whenever a message is sent to our Channel.

```javascript
let channel = socket.channel("ping:me", {})
let payload = {key: "value"}
channel.push("event", payload)
  .receive("ok", resp => console.log("OK response:", resp))
  .receive("error", resp => console.error("ERROR response:", resp))
  .receive("timeout", resp => console.error("Message timeout after 10 seconds (configurable)"))
```

> A payload is sent as the second parameter to push . This payload can be any
> JSON compatible object. Errors are handled via the "error" event similarly to
> the "ok" event.

#### Receiving Messages with the JavaScript Client

> A Channel can send messages to a connected client at any time, not just in
> response to an incoming message.

Send a message from the Channel via `iex`:

```elixir
iex> HelloSocketsWeb.Endpoint.broadcast "ping:me", "request_ping", %{data: "test"}
```

That is then intercept by the Channel handler:

```elixir
# the interception is to augment the data sent with `from_node` info, and map
# to `send_ping` event on the client.
def handle_out("request_ping", payload, socket) do
  push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
  {:noreply, socket}
end
```

The client receives it with:

```javascript
channel.on("send_ping", payload => {
  console.log("ping requested", payload)
  channel.push("ping")
    .receive("ok", resp => console.log("ping:", resp.ping))
})
```

> The `on` callback of our client channel is used to register incoming message
> subscriptions. The first argument is the string name of the event that we want
> to handle; this requires us to know the exact event name for incoming mes-
> sages. For this reason, it is a good idea to not use dynamic event names. You
> can instead place dynamic information in the message payload.

> Try loading multiple instances of the web page and broadcasting again. You
> will see that every connected client receives the broadcast. This makes
> broadcasting a very powerful way to send data to all connected clients. Replies,
> on the other hand, will only be sent to the client that sent the message.

#### JavaScript Client Fault Tolerance and Error Handling

> It's a fact of software that errors and disconnections will occur. We can best
> prepare our application for these inevitable problems by handling caught
> errors ourselves and by ensuring that our client handles unexpected errors.
>
> One of the great features of the Phoenix JavaScript client is that it tries very
> hard to stay connected. When the underlying connection becomes disconnect-
> ed, the client will automatically attempt reconnection until it's successful.
> Reconnection is fairly aggressive, which is often exactly what we want,
> although we can customize it to be more or less aggressive based on our
> application's needs.

> In addition to Socket reconnection, the underlying Channel subscriptions try
> to maximize time spent connected. We saw in the previous example that the
> ping Channel became reconnected when the Socket did. The Channel may
> become disconnected for other reasons as well, such as when an application
> error occurs.

> Our PingChannel crashed when it encountered the unknown event, causing the 
> Process to die.
> The JavaScript client knows the Channel crashed, because it’s sent a "phx_error"
> event, and immediately attempts to reconnect. It’s able to establish the Channel
> again because our problem only occurs when we sent an incorrect message.
