# CHAPTER 2 - Connect a Simple Websocket

You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## Connect a Simple Websocket

> Real-time systems are all about getting data from the server to the user, or
> vice versa, as quickly and efficiently as possible. A critical piece of a real-time
> system is the communication layer that sits between the server and the user.
> The user may be on a browser, a mobile app, or even another server. This
> means that we want to pick a communication layer that can work well in a
> variety of different circumstances, from high-latency mobile connections to
> very fast connections.

> Understanding Web-Sockets is crucial in order to build and deliver real-time 
> applications to users.

> You can build a real-time system without understanding all the different
> layers, such as WebSockets, but lacking this knowledge may hurt you in the
> long run.

### Why WebSockets?

> We'll be using WebSockets as the primary communication layer in this book
>because of these strengths:
> * WebSockets allow for efficient two-way data communication over a single
> TCP connection. This helps to minimize message bandwidth and avoids
> the overhead of creating frequent connections.
> * WebSockets have strong support in Elixir with the cowboy web server. 1
> They map very well to the Erlang process model which helps to create
> robust performance-focused applications.
> * WebSockets originate with an HTTP request, which means that many
> standard web technologies such as load balancers and proxies can be
> used with them.
> * WebSockets are able to stay at the edge of our Elixir application. We can
> change out our communication layer in the future if a better technology
> becomes available.
