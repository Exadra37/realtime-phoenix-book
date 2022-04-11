# CHAPTER 4 - RESTRICT SOCKET AND CHANNEL ACCESS 

You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## Restrict Socket and Channel Access

> We'll use a Phoenix.Token to pass authentication information from the server 
> to the view, and then will use that to add Channel access restriction to the
> JavaScript client. You'll learn when to use a single Socket or multiple 
> Sockets in your applications, based on the restriction needs of your system.

### Why Restrict Access?

> It has been a common occurrence to hear about data leaks from improperly
> secured data or endpoints. This type of security issue can hit any application,
> including ones based on Phoenix Channels.

> There are two different types of access restriction that we'll focus on. The first
> type of restriction, authentication, prevents non-users from accessing your
> application. If someone malicious is able to discover your Socket connection
> URL and then successfully connect, they may be able to access more of your
> system. The second type of restriction, authorization, prevents users from
> accessing each other's data. If your application exposed information about a
> particular user, even non-sensitive information, you would want only that
> specific user to see it.

> When you want to prevent non-users from connecting to your application, you 
> add authentication to the Socket. When you want to restrict access to user 
> data, you add authorization to the Channel and topic.

> You'll use both types of restriction to fully secure your real-time application.

### Add Authentication to Sockets

> You can use Socket authentication when you want to restrict a client's access
> to a real-time connection.

> When you add authentication checks at the very edge of your
application, in the Socket, you’re able to avoid writing code that checks if
there is a logged in user lower in the system. This improves your system's
maintainability because your user session check exists in a single location.

> You can add Socket authentication to your application by using a securely
> signed token.

### Securing a Socket with Signed Tokens

> WebSockets lack CORS (cross-origin resource sharing) restrictions that are
> used by other types of web requests. The biggest vulnerability that this
> exposes is a cross-site request forgery (CSRF) attack. In a CSRF attack, a
> different website controlled by the attacker initiates a request to your
> application. The attacker may be able to use this connection as if they were
> the user, receiving private data about the user or making changes to the
> user's data.

### Different Types of Tokens

> Alternatives to Phoenix.Token can help us in these situations. A very common
> web standard for authentication is the JSON Web Token (JWT). 1 JWTs are
> cryptographically secure but not encrypted (an encrypted variant called JWE
> does exist), so they meet the same security standard as Phoenix.Token . One large
> difference, however, is that JWT is a standardized format that can be con-
> sumed easily in nearly any language, including the front-end client.

> Whether you're using Phoenix Tokens, JWT, or another technology, it's
> important to set the token's expiration to a low-enough value. A token is the
> user's way to get into your system, and a user has access for the duration of
> the token. Pick a token duration that is long enough to be convenient, but
> short enough to provide security for your users—I usually default to 10 min-
> utes. There are techniques that can invalidate tokens before they're expired,
> such as token blocklists, but we wont cover them in this book.

In my opinion 10 minutes is huge for the scenario of authenticating a socket, 
because when the user loads the web page, the connection to the socket will be
established immediately with the provided token on page load, therefore the 
token expiration should be around 10 seconds, maybe 20 seconds, but if you want 
to allow time for really sluggish connections. For other scenarios you will
need to adjust the expire time accordingly to the situation.
