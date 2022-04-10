// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/hello_sockets_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/hello_sockets_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/hello_sockets_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/hello_sockets_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case 42:
let channel = socket.channel("hello:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.error("Unable to join", resp) })


channel = socket.channel("ping:me", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully to channel: ping ", resp) })
  .receive("error", resp => { console.error("Unable to join to channel: ping", resp) })

/**
 * SENDING MESSAGES
 */

console.log("send ping")
channel.push("ping")
  .receive("ok", resp => console.log("receive", resp.ping))

console.log("send pong")
channel.push("pong")
  .receive("ok", resp => console.log("won't happen"))
  .receive("error", resp => console.error("won't happen yet"))
  .receive("timeout", resp => console.error("pong message timeout"))

console.log("send param_ping > error: true")
channel.push("param_ping", {error: true})
  .receive("error", resp => console.error("param_ping error:", resp))

console.log("send param_ping > error: false")
channel.push("param_ping", {error: false})
  .receive("ok", resp => console.log("param_ping ok:", resp))

console.log("send invalid")
channel.push("invalid")
  .receive("ok", resp => console.log("won't happen"))
  .receive("error", resp => console.error("won't happen yet"))
  .receive("timeout", resp => console.error("invalid event timeout"))

/**
 * RECEIVING MESSAGES
 */

channel.on("send_ping", payload => {
  console.log("ping requested", payload)
  channel.push("ping")
    .receive("ok", resp => console.log("ping:", resp.ping))
})

export default socket
