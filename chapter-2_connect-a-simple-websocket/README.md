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

### Connecting our First WebSocket

This part is about creating the Phoenix app `hello_websockets` to then learn how websockets work.

I ma using Phoenix `1.6.6`, thus the book instructions don't work anymore because LiveView is now the default, and the way we enable Phoenix Channels seem to have changed.

Now we need to first generate the channels with:

```bash
mix phx.gen.channel Hello  
```

Output:

```text    
* creating lib/hello_sockets_web/channels/hello_channel.ex
* creating test/hello_sockets_web/channels/hello_channel_test.exs

The default socket handler - HelloSocketsWeb.UserSocket - was not found.

Do you want to create it? [Yn] Y
* creating lib/hello_sockets_web/channels/user_socket.ex
* creating assets/js/user_socket.js

Add the socket handler to your `lib/hello_sockets_web/endpoint.ex`, for example:

    socket "/socket", HelloSocketsWeb.UserSocket,
      websocket: true,
      longpoll: false

For the front-end integration, you need to import the `user_socket.js`
in your `assets/js/app.js` file:

    import "./user_socket.js"
```

Afterwards we need to follow the above instructions to enable the Phoenix Channel socket.

Before we start the server we need to fix [this bug](https://github.com/phoenixframework/phoenix/issues/4752) I filled for the Phoenix Channel generator. 

Open the file at `assets/js/user_socket.js` and change this code:

```javascript
let channel = socket.channel("room:42", {})
``` 
to this:

```javascript
let channel = socket.channel("hello:lobby", {})
``` 

Now that the channel name is fixed we start the server:

```bash
iex -S mix phx.server
```

Then we visit http:localhost:4000 and look for this output in the server logs:

```
CONNECTED TO HelloSocketsWeb.UserSocket in 104µs
  Transport: :websocket
  Serializer: Phoenix.Socket.V2.JSONSerializer
  Parameters: %{"token" => "undefined", "vsn" => "2.0.0"}

[info] JOINED hello:lobby in 68µs
```
