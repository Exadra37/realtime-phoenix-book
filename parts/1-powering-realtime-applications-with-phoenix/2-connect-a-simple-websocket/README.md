# CHAPTER 2 - Connect a Simple WebSocket

You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## Connect a Simple WebSocket

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

I am using Phoenix `1.6.6`, thus the book instructions don't work anymore because LiveView is now the default, and the way we enable Phoenix Channels seem to have changed.

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

### WebSocket Protocol

https://datatracker.ietf.org/doc/html/rfc6455


#### Establishing the Connection

> A WebSocket starts its life as a normal web request that becomes “upgraded”
> to a WebSocket.

> WebSockets operate over a TCP socket using a special data protocol, with the
> initial HTTP request ensuring that the connection is compatible with browsers
> and server proxies. The same TCP socket that the HTTP connection request
> went over becomes the data TCP socket after the upgrade—this allows Web-
> Sockets to only use a single socket per connection. WebSockets were designed
> for allowing browsers to connect to a TCP socket through HTTP, but it is
> completely acceptable to use them in non-browser environments such as a
> server or mobile client.

> To summarize, a WebSocket connection follows this request flow:
> 1. Initiate a GET HTTP(S) connection request to the WebSocket endpoint.
> 2. Receive a 101 or error from the server.
> 3. Upgrade the protocol to WebSocket if 101 is received.
> 4. Send/receive frames over the WebSocket connection.

After upgrading the connection on `3` to a websocket we have a bidirectional 
channel open between the server and the client that allows to send and receive
messages on `4`.

#### Sending and Receiving Data

> the important thing to note is that a WebSocket is capable of sending messages
> (green background) and receiving messages (white background). This two-way 
> data transmission can happen in both directions simultaneously. A connection 
> which is capable of two-way data transmission is called a full-duplex 
> connection.

> WebSockets transmit data through a [data framing](https://datatracker.ietf.org/doc/html/rfc6455#section-5) protocol. We can't see it
> with the DevTools, but it's worth knowing this provides security benefits and
> allows WebSocket connections to work properly through different networking
> layers. These traits allow us to more confidently ship WebSocket-powered
> applications into production.

> The WebSocket protocol contains extensions that provide additional 
> functionality. Extensions are requested by the client using the
> Sec-WebSocket-Extensions request header. The server can optionally use any of 
> the proposed extensions and return the list of active extensions to the client
> in a response header named Sec-WebSocket-Extensions. 

> WebSocket data frames are not compressed by default, but can be compressed by 
> using the per message deflate extension. **This feature allows bandwidth to be 
> reduced at the cost of processing power**, which is a benefit for some 
> applications.

#### Staying Alive, Keep-alive

> The WebSocket protocol specifies [Ping and Pong](https://datatracker.ietf.org/doc/html/rfc6455#section-5.5.2) frames 10 which can be used
> to verify that a connection is still alive. These are optional, though, and you'll
> soon see that Phoenix doesn't use them. Instead, clients send heartbeat-data
> messages to the Phoenix Server they're connected to every 30 seconds. The
> Phoenix WebSocket process will close a connection if it doesn't receive a ping
> within a timeout period, with 60 seconds the default. With Phoenix, it is
> possible to use a WebSocket ping control frame to keep the WebSocket 
> connection alive, but the official Phoenix client doesn't use it.

> A predictable heartbeat for the connection turns out to be very useful. A
> connection can be dead but not closed properly; this causes the connection
> to stay active on the server. A connection that is active but without a client
> on the other side wouldn't be sending a heartbeat, so it closes gracefully after
> a short period of time.

> It is useful that the client manages the heartbeat rather than the server. If the
> server is in charge of sending pings to a client, then the server is aware of the
> connectivity problem but cannot establish a new connection to the client. If a
> connectivity problem is detected by the client via its ping request, the client can
> quickly attempt to reconnect and establish the connection again.

#### Security

> Our HelloSocket example violates one of the most important rules of WebSocket
> connections: always use wss:// URIs to ensure a secure connection. We use
> ws:// in our example because it doesn’t involve signing a local certificate for
> SSL, but you should always use wss protocol in production to ensure security.
> If you are using https to access your webpage, then you are required to use
> the wss protocol by the browser.

> The Origin header of every connection request should be checked to ensure that 
> it is coming from a known location. It is possible that this header was spoofed
> by a non-browser client, but browser security increases when we check the Origin
> header

> WebSockets do not follow the same rules as standard web requests when it
> comes to cross-origin resource sharing (CORS)—the WebSocket connection
> request doesn’t use CORS protections at all. Cookies are sent to the server,
> even if the page initiating the request is on a different domain than what the
> cookies specify. These cookies aren’t readable by the initiating page, but they
> would allow access to the server when access should be denied. There are
> strategies that can help solve this problem, such as origin checking or cross-
> site request forgery (CSRF) tokens.

> As a way to prevent CSRF attacks, Phoenix has historically disallowed cookie
> access when establishing a WebSocket connection. Phoenix now supports
> access to the session when a CSRF token is provided to the WebSocket connection.

### Long Polling, a Real-Time Alternative

> It is important for the maintenance of our application that we do not design 
> it solely around WebSocket usage. Remember, we have a WebSocket-powered 
> application, not a WebSocket application.

> We can even run WebSockets in tandem with HTTP long polling.

#### What is Long Polling?

> HTTP [long polling](https://tools.ietf.org/html/rfc6202#section-2) is a 
> technique that uses standard HTTP in order to asynchronously send data to a 
> client.

> Long polling uses a request flow as follows:
> 1. The client initiates an HTTP request to the server.
> 2. The server doesn’t respond to the request, instead leaving it open. The
> server will respond when it has new data or too much time elapses.
> 3. The server sends a complete response to the client. At this point the client
> is aware of the real-time data from the server.
> 4. The client loops this flow as long as the real-time communication is
> desired.

> The key component of the long polling flow is that the client's connection to
> the server remains open until new data is received.

#### Should You Use Long Polling?

> There is a more exhaustive [list of issues](https://tools.ietf.org/html/rfc6202#section-2.2) maintained by the IETF, 12 which is
> a must read if you're going to use long polling in production.
> 1. Request headers are processed on every long poll request. This can,
> potentially, dramatically increase the number of transmitted bytes which
> need to be processed by the server. This isn’t optimal for performance.
> 2. Message latency can be high when a poor network is being used. Dropped
> packets and slower data transit times can make latency much higher because 
> multiple connections have to complete in order to reestablish the long polling
> connection. This can affect how real-time the application feels.

> Both of these problems can affect performance and scalability of our 
> application, which would be bad if the system becomes heavily used. WebSockets
> are not prone to these performance issues because the data transmission
> protocol is much lighter than full HTTP requests, requiring less data overhead
> and network round trips.

> There are times that long polling can be useful, however. Long polling connec-
> tions can be load-balanced across multiple servers easily, because the con-
> nections are being established often. WebSockets can be tricky to load balance
> if the connections have a long life; longer connections provide fewer opportu-
> nities to change which server a client is connected to. Another benefit of long
> polling is that it can transparently take advantage of protocol advancements,
> such as future versions of HTTP. Google, a well-known innovator of internet
> protocols, leverages a custom form of long polling to power certain real-time
> applications.

> Phoenix ships with both a WebSocket and a long polling communication layer
> out-of-the-box. A client can change from WebSocket to long polling if some-
> thing goes wrong, such as poor network connectivity.

> There are other real-time communication techniques that Phoenix does not ship 
> with natively. [Server-sent events](https://hexdocs.pm/sse/readme.html#content), 
> for example, provides one-way data flow from the server to a client.

### WebSockets and Phoenix Channels

> WebSockets map very well to the Erlang/OTP actor model and are leveraged
> by one of the stars of Phoenix: Channels. WebSockets are the primary 
> communication layer for Channels. This provides Channels with a solid 
> foundation on which to build real-time applications.

> Maybe you're worried that WebSockets will cause high resource usage in your
> application. Don't worry! Phoenix and Elixir make it easy to have tens of
> thousands of connections on a single server. Each connected Channel and
> WebSocket in your application has independent memory management and garbage
> collection because of OTP processes. An advantage of this process-based 
> architecture is that WebSocket connections which are not being used often can 
> be stored in a hibernated state, which consumes very little memory. This is 
> great for scalability.

> Channels use several levels of processes which provide fault tolerance and 
> reduced memory usage across our application. This is very important for 
> scaling our real-time application because it prevents application bottlenecks 
> (points in code that slow down our system) from forming.

### Wrapping Up

> The WebSocket protocol provides a strong real-time communication layer for
our real-time applications. WebSockets start as normal HTTP requests before
being upgraded to TCP sockets for data exchange. This allows WebSockets
to work well with current web technologies and also lets them leverage faster
data transport by using a single connection with minimal protocol overhead
for each message.
