# CHAPTER 5 - DIVE SEEP INTO PHOENIX CHANNELS

You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## Dive Deep into Phoenix Channels

> We’ll first cover the unreliable nature of internet connections and consider
> how we can build applications that survive the strange things that can happen
> with real users. Flaky internet connections, bugs in an application, and
> server restarts can all lead to connection trouble for users.

### Design for Unreliable Connections

> Clients connect to our real-time application using a long-lived connection.
> The client’s connection can close or fail at any point; we need to consider this
> and write code to recover from this when it happens.

> There are certainly expected reasons for a connection to disconnect, such as
> a user leaving the application, changing pages, or closing their laptop while
> the application is loaded. There are also more unpredictable reasons that
> cause a connection to (erroneously) disconnect. A few examples of this are:
> * A client’s internet connection becomes unstable and drops their connection
> without any other changes.
> * A bug in the client code causes it to close the connection.
> * The server restarts due to a routine deploy or operational issue.

#### Channel Subscriptions

> In the event of a client disconnecting, the Channel subscriptions are no longer
> present on the server because the memory is collected. For example, a client 
> could be connected to one Socket and three Channels. If the client became 
> disconnected from the server, then the server has zero Sockets and zero Channels. 
> When the client reconnects to the server, the server has one Socket and zero 
> Channels. In this scenario all of the Channel information has been lost from the
> server, which means that our application would not be working properly.

> Throughout this scenario, the client knows that it’s supposed to be connected
> to the server and which Channel topics it should be connected to. This means
> that the client can reconnect to the server (creating one Socket) and then
> resubscribe to all of the topics (creating three Channels). This puts the client
> back in a correct state, with an amount of downtime based on how long it
> took to establish the connection and subscriptions.

> The official Phoenix JavaScript client handles this reconnection scenario for
> us automatically. If you’re using a non-standard client implementation, then
> you need to specifically consider this event to prevent your clients from ending
> up in an incorrect state after reconnection.

#### Keeping Critical Data Alive

> The processes that power our real-time application can shut down or be killed
> at any point. When a client disconnects, for example, all of the processes that
> power that client’s real-time communication layer (Socket and Channels) are
> shut down. The data that is stored in a process is lost when the process shuts
> down. We do not have any important information in the real-time communi-
> cation processes by default, but we often will enrich our Channel processes
> with custom state that powers our application.

> When we store custom state in a process in our application, we must consider
> what happens when the process shuts down. There is a useful rule of thumb
> that we can use when designing our systems: all business-related data should
> be stored in persistent stores that can withstand system restarts.

> You can follow these best practices to set yourself up for the most success:
> * Utilize a persistent source of truth that the Channel interacts with, such
> as a database, for business data.
> * Create a functional core that maintains boundaries between the commu-
> nication layer and the business logic, like in Designing Elixir Systems with
> OTP.
> * Consider the life cycle of any processes linked to or otherwise associated
> with your Channel process.

> These practices will help you focus on the true responsibility of a Channel—
> real-time communication—and avoid custom business logic being implemented
> in your Channels.

> These rules do not mean that you are unable to store critical business data
> in process memory. Doing so can have significant speed and scalability ben-
> efits. You should, however, be able to recover the current state of the data if
> the process is killed at any point.

#### Message Delivery

> Channels deliver messages from the server to a client with some limited
> guarantees about how these messages are delivered. These guarantees will
> often be okay for your applications, but you should understand the limitations
> to know if they will not work for you.

> Phoenix Channels use an at-most-once strategy to deliver messages to clients.
> This means that a given message will either appear zero or one time for a
> client. A different approach is at-least-once message delivery, where a message
> will be delivered one or more times. It is not possible to have exactly-once
> message delivery, due to uncertainty in distributed systems.

> Phoenix’s at-most-once message delivery is a bit of a problem on the surface:
> how can we work with a system that may not deliver a message? This is a
> trade-off that Phoenix makes in how it implements real-time messaging. By
> having an at-most-once guarantee with message delivery, Phoenix prevents
> us from needing to ensure that every message can be processed multiple
> times, which is potentially a much more complex system requirement.

> The at-most-once strategy can be seen in action when we observe how PubSub
> is used in broadcasting messages across our cluster. PubSub has a local com-
> ponent that is very likely to always succeed in broadcasting the message to the
> local node. PubSub also has a remote component that sends a message when
> a broadcast occurs. PubSub will try only once to deliver the message and does
> not have the concept of acknowledgment or retries. If the message is not delivered
> for some reason, then that message would not make it to remotely connected
> clients.

> We also see this strategy at work when we observe how Phoenix delivers
> messages to the client. Phoenix sends messages to connected clients but
> doesn’t look for any type of acknowledgment message. If you want guaranteed
> at-least-once delivery, then you will need to write code to add acknowledgment,
> something we aren’t going to cover due to its complexity. The important thing
> to know is that you are able to fully customize this behavior if you need to.
> In practice, however, you usually want the at-most-once strategy that comes
> standard with Phoenix.

### Use Channels in a Cluster

> It is critical to run multiple servers when you are deploying a production
application. Doing so provides benefits for scalability and error tolerance.

> Elixir makes connecting a cluster of BEAM nodes very easy. However, we
> have to ensure that we’re building our application to run across multiple
> nodes without error. Phoenix Channels handles a lot of this for us due to
> PubSub being used for all message broadcasts, which we’ll look at next.

#### Challenges with Distributed Channels

> A distributed application has potential problems that a single-node application
> won’t experience. A single-node application may be the right call in some 
> circumstances, such as a small internal application, but we often must deliver our 
> applications to many users that require the performance and stability that are 
> provided by distribution.

> Here are a few of the challenges that we’ll face when distributing our applica-
> tion. These problems are not specific to Elixir—you would experience the
> same problems when building a distributed system in any language.
> * We cannot be sure that we have fully accurate knowledge of the state of
> remote nodes at any given time. We can use techniques and algorithms
> to reduce uncertainty, but not completely remove it.
> * Messages may not be transmitted to a remote node as fast as we’d expect,
> or at all. It may be fairly rare for messages to be dropped completely, but
> message delays are much more common.
> * Writing high-quality tests becomes more complicated as we have to spin
> up more complex scenarios to fully test our code. It is possible to write
> tests in Elixir that spin up a local cluster to simulate different environments.
> * Our clients may disconnect from a node and end up on a different node with
> different internal state. We must accommodate this by having a central source 
> of truth that any node can reference; this is most commonly a shared database.

### Customize Channel Behavior

> A Phoenix Channel is backed by a GenServer that lets it receive messages and
store state. We can take advantage of this property of Channels to customize
the behavior of our Channel on a per-connection level. This allows us to build
flows that are not possible (or would be much more complex) with standard
message broadcasting, which can’t easily send messages to a single client.

> We can’t customize the behavior of Sockets as much due to their process structure.
