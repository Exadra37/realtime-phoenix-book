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

