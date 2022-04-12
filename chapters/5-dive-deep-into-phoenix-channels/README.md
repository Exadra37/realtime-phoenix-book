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
