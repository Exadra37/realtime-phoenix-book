# CHAPTER 6 - AVOIDING PERFORMANCE PITFALLS


You can buy the [Real-Time Phoenix - Build Highly Scalable Systems with Channels](https://pragprog.com/titles/sbsockets/real-time-phoenix/) book, by Stephen Bussey, with the 35% discount code from the [Elixir Forum Giveaways](https://elixirforum.com/t/elixir-forum-update-2022-the-100-000-issue/45299) page.


## Avoiding Performance Pitfalls

> This chapter looks at several common scaling challenges and best practices
> to help avoid performance issues as you develop and ship your application.
> We’re covering these topics before we build a real application (in part II)
> because it’s important to consider them at the design stage of the development
> process, and not after the application is already written.

> The following performance pitfalls are a collection of common problems that
> can affect applications. You’ll experience many other challenges when building
> and shipping an application, but we’ll focus on these three, because they are
> applicable to all real-time applications.
> 
> #### Unknown application health
> We need to know if our deployed application is healthy. When our appli-
> cation experiences a problem, we’re able to identify root cause by looking
> at all of our metrics. You’ll see how to add measurements to our Elixir
> applications using StatsD.
> 
> #### Limited Channel throughput
> Channels use a single process on the server to process incoming and
> outgoing requests. If we’re not careful, we can constrain our application
> so that long running requests prevent the Channel from processing. We’ll
> solve this problem with built-in Phoenix functions.
>
> #### Unintentional data pipeline
> We can build a pipeline that efficiently moves data from server to user.
> We should be intentional in our data pipeline design so that we know the
> capabilities and limitations of our solution. We’ll use GenStage to build
> a production-ready data pipeline.

### Measure Everything

> A software application is made up of many interactions and events that
> power features. The successful combination of all the different events in a
> feature’s flow cause it to work properly and quickly. If even a single step of
> our application encounters an issue or slowdown, the rest of that flow is
> affected. We need to be aware of everything that happens in our application
> to prevent and identify problems.

> It is impossible to effectively run a decently sized piece of software without
> some form of measurement. Software becomes a black box once deployed,
> and having different view ports into the application lets us to know how well
> things are working.

#### Types of Measurements

> The best way to know if our application is behaving correctly is to place
> instrumentation on as many different events and system operations as possi-
> ble.

> Here are a few of the simple but effective ways that you can measure things:
> * Count occurrences — The number of times that an operation happens. We
> could count every time a message is pushed to our Channel, or we could
> count every time a Socket fails to connect.
> * Count at a point in time — The value of a component of our system at a
> moment of time. The number of connected Sockets and Channels could
> be counted every few seconds. This is commonly called a gauge in many
> measurement tools.
> * Timing of operation — The amount of time that it takes for an operation
> to complete. We could measure the time taken to push an event to a client
> after the event is generated.

> Each measurement type is useful in different situations, and there isn’t a
> single type that’s superior to the others. A combination of different measure-
> ments combined into a single view (in your choice of visualization tool) can
> help to pinpoint an issue. For example, you may have a spike in new connec-
> tion occurrences that lines up with an increase in memory consumption. All
> of this could contribute to an increase in message delivery timing. Each of
> these measurements on its own would tell you something, but not the full
> picture. The combination of all of them contribute to understanding how the
> system is stressed.
