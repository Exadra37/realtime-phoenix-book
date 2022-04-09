# CHAPTER 1 - Real-Time is Now

You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## Real-Time is Now

> In this chapter, we'll look at what a real-time system means to us throughout
> this book. We'll see several aspects of how an application can be scalable and
> understand the tension that exists between the different types of scalability.
> We'll see how Elixir can help enable the creation of real-time systems in a
> way that maximizes all aspects of scalability.

### The Layers of a Real-Time System

> Real-time applications consist of clients, a real-time communication layer, and
> back-end servers working together to achieve business objectives. The coopera-
> tion and proper function of each layer is important in developing a successful
> application.

> There are different levels of guarantee in a real-time system. Hardware systems
> that have strict time guarantees are considered to be “hard” real-time. For
> example, an airplane's control system needs to always respond within strict
> time limits. This book will look at “soft” real-time applications, also known
> as near real-time. Soft real-time applications can have several seconds of
> delay when updating the user's view, with a goal of minimizing the amount
> of time the update takes. A soft real-time application should update to the
> correct state without user intervention.

> Clients connect to a server via a two-way communication layer. Each server
> utilizes a server-to-server communication layer to ensure that real-time
> messages are delivered across a cluster to the appropriate user. Let's take a
> closer look at each layer.

#### On the Client 

> One of the most important functions of a client, in the context of real-time
> applications, is to maintain a connection to the server at all times. Without 
> the proper real-time communication layer, the application won't function as 
> expected. This can prove challenging because many users may be accessing the
> application from less-than-ideal networks such as a mobile phone or weak Wi-Fi
> connection.

#### Communication Layer

> The communication layer facilitates data exchange between a server and a client.
> The communication layer affects how the user experiences the application—if
> data is not sent instantly, then the application will feel slow. The communication
> layer needs to be reliable—any disconnection could prevent data from being
> exchanged. In order to reduce latency, the connection between a client and
> the server is often persistent. A persistent connection is one that lasts for
> many requests or even for as long as the client wants to stay connected.

> It's important that server and client application code is not tied to a 
> particular communication technology.

> If clients and servers are tightly coupled to a communication layer, it may be
> very difficult to implement a new communication layer in the future. This
> reduces the maintainability of an application.

#### On the Server

> In a real-time application, a client connects to a single server using the
> application's communication layer. The server will keep the connection open
> for an extended period of time, often as long as the client wants.

> One major difference between traditional web requests and real-time requests 
> is statefulness. 
> HTTP web requests are stateless, meaning that the server doesn't maintain
> state between requests. A client making HTTP requests must send state, such
> as cookies, with each request. A real-time server can associate state, such as
> user or application data, with a specific connection. This allows real-time
> systems to avoid setting up the world with each request, which means that
> your application will do less work and respond to requests faster.

> It is important for resilience and performance to have multiple servers 
> capable of serving requests.

> In a real-time application, it is often desirable and even required to have 
> servers that can talk to each other. For example, real-time chat servers would 
> communicate with each other about who is connected and who needs to receive a 
> particular message.

> Applications that maintain state and behavior across multiple instances are
> called distributed systems. Distributed systems can bring many benefits,
> especially in performance, but they also come with many challenges.

> Every layer is important in the proper functioning of our
> application, but the server has the highest potential for encountering 
> scalability problems due to the complexity of dealing with many independent 
> clients.


### Types of Scalability

> We have to consider multiple types of scalability such as performance, 
> maintenance, and cost in order to be successful with our applications over 
> long periods of time.

#### Scalability of Performance

> An application that has successfully scaled performance-wise will have similar, 
> or at least acceptably slower, response times with 1000 client connections as 
> it does with 50,000 client connections.

> There are many aspects of performance that will affect our real-time applica-
> tion. As with standard web applications, the data store will be a very likely
> culprit of performance problems as an application grows. There are perfor-
> mance considerations that affect real-time applications but may not affect
> non-real-time applications. For example, you will need to share information
> about a large number of real-time connections between the servers of your
> application, which is something you wouldn't need to do in a non-real-time
> application.

#### Scalability of Maintenance

> Maintenance occurs when we add new features, debug issues, or ensure uptime of
> an application over time.

> Poor maintainability means that developers have to spend more time—often in 
> frustration—when adding features or diagnosing existing problems in an 
> application.

> Maintenance is a hard concern to optimize because we can often be blind to
> things that will be problematic in the future. We may leverage a new technique
> or tool that we anticipate will make changes easier in the future, but the 
> exact opposite could happen! Our perception of what is maintainable could also
> change over time; new developers on a project may not have as much experience 
> with a technology, which makes maintenance more challenging for them.

> Leveraging programming best practices and clear boundaries in our application
> is a time-tested way to ensure future maintenance.

> Layers can nominally increase the amount of computation in our application,
> but well-designed layers give us many maintenance benefits by making it
> easier for us to make changes.

#### Scalability of Cost

> As developers, we are often separated from the financial cost of our 
> applications. However, we are able to control several different components 
> that contribute to the cost of our application. We are able to conserve, or 
> spend, server resources such as CPU, memory, and bandwidth. We will also 
> experience costs associated with future development time that we want to 
> minimize.

### Tension of Scalability

> The different types of scalability exist in tension with each other. This can
> end up causing our applications to reduce one type of scalability when we
> increase another.

> It would be ideal if we could maximize every type of scalability perfectly, 
> although the reality is that this is very difficult to do. You might know the 
> old rule of thumb: “fast, reliable, cheap - pick two.”

#### Performance vs. Cost

> You can often increase application performance by paying for additional
> server resources—throwing hardware at the problem. This technique is used
> to improve performance without addressing the root cause that is causing
> the performance problem.

> It may also be early in an application's existence and new feature development
> is prioritized over performance.

> An example of acceptably reducing cost while also reducing potential 
> performance is to scale the number of servers down during periods of 
> application inactivity.

#### Performance vs. Maintenance

> Writing high-performance code can also mean writing complex and harder to 
> maintain code. One way to increase application performance is to reduce
> or remove boundaries in code. For example, tightly coupling a communication
> layer to the server implementation could allow for a more-optimized solution
> that directly processes incoming requests. However, boundaries exist for the
> purpose of creating more understandable and maintainable code. By removing
> the layers, we could potentially reduce the ability to maintain the code in the
> future.

> Most applications should focus on maximizing maintenance ability as this
> allows new features to be easily added over time. However, there may come
> a point when performance needs become greater than the need to add new
> features.

#### Maintenance vs. Cost

> Maintenance involves people, and people are expensive. By reducing the 
> difficulty of maintenance, you can save development hours in the future and 
> reduce cost. You can also minimize cost by not fixing technical debt over time,
> which could reduce immediate costs but potentially increase maintenance costs.

> Maintenance and cost are often very important to technical managers or non-
> technical stakeholders in an organization. As developers, we must consider
> their perspective to help ensure the long-term success of our projects.

> All of the various components of scalability affect each other. The real world
> is full of trade-offs and decisions that may be outside of your control.
> Understand the concerns of scalability with key stakeholders in order to
> inform decisions you make on a project.

### Achieving Real-Time in Elixir

> Elixir builds on top of Erlang/OTP to provide an excellent foundation for soft
> real-time applications. 

> Elixir leverages lightweight virtual machine processes, often implemented as 
> GenServers, that allow for encapsulation and modeling of the various 
> components of a real-time system.

> It's possible to scale Elixir applications to multiple cores without any 
> special constructs, just as it is simple to connect servers together to form 
> a cluster.

> Any system that we write, especially a real-time system where time matters,
> should have reliable isolation of data and isolated error handling.

> Data isolation and error isolation are handled for us, nearly freely, by using 
> separate OTP processes for different elements of our real-time system.

> it is possible to experience issues in an Elixir application when using a 
> software design that doesn't take advantage of Elixir's strengths.

### Wrapping Up

> Real-time applications help you to win your users’ trust by creating an 
> experience that always reflects the current state of their data.

> Real-time applications consist of clients, a real-time communication layer, 
> and back-end servers working together to achieve business objectives.

> You must plan for scalability when building a real-time application. There
> are multiple types of scalability that are important to consider: performance,
> maintenance, and cost. These different aspects of scalability are always in
> tension with each other. They influence the different decisions you make in
> how you write and run applications.

> Elixir is a not-so-secret weapon for developing real-time applications, and
> using it creates a setting for success. It allows us to maximize the different
> aspects of scalability for an application while reducing trade-offs. This isn't
> necessarily unique to Elixir, but it has allowed it to become positioned as a
> forerunner in the real-time application space.
