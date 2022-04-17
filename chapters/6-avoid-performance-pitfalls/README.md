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

#### Collect Measurements using StatsD

> StatsD is a daemon that aggregates statistics; it takes measurements sent
> by our application and aggregates them into other back ends that collect the
> stats. Many APMs provide a StatsD back-end integration; this makes StatsD
> a great choice for collecting measurements.

> It is easy to get started with StatsD in Elixir by using the Statix 1 library. 
> This library has a simple interface with functions that correspond to StatsD 
> measurement types.

#### Visualizing Measurements

> We are emitting our StatsD measurements, but we are not yet able to make
> use of them. We need a tool for that. There are many commercial and open-
> source tools that operate on StatsD metrics. It is outside of the scope of this
> book to learn how to use these tools, but here’s what you can ultimately do
> with these metrics.
> * **Visualize metrics with graphs**
> You can create graphs of your different measurements. You can even
> combine and compare graphs to correlate potential problems.
> * **Produce dashboards for your team**
> You can combine graphs and other visualizations into a “single pane of
> glass.” This allows you to quickly see the health of your system, maybe
> from a shared monitor in your office.
> * **Get alerted to problems**
> Many metrics systems allow you to set up alerts on values of your mea-
> surements. For example, you may want to get an alert when your Channel
> begins taking a certain amount of time to respond to a particular request.
> * **Detect anomalies**
> Some metrics systems are capable of detecting anomalies in your metrics
> without you configuring known thresholds. This can be useful in identify-
> ing unexpected problems. For example, a metric system could automati-
> cally detect that your metric values are outside of several standard devia-
> tions and then alert you to a potential problem.

> All of these features allow you to understand more about the state of your
> system, closing one of the performance pitfalls. You can respond to any issues
> or plan capacity for your system when you have this knowledge. You should
> add measurements early in your application’s development so you can iden-
> tify potential problems early—before a problem affects users.

### Keep Your Channels Asynchronous

> Elixir is a parallel execution machine. Each Channel can leverage the princi-
> ples of OTP design to execute work in parallel with other Channels, since the
> BEAM executes multiple processes at once. Every message processed by a
> Channel, whether incoming or outgoing, must go through the Channel process
> in order to execute. It’s possible for this to stop working well if we’re not
> careful about how our Channel is designed. This is easiest to see when we
> have an example of the problem in front of us.

```elixir
# To simulate a bottleneck in the Channel, where there is no parallelism
# present, even though we're using one of the most parallel languages available!
# The root cause of this problem is that our Channel is a single process that
# can handle only one message at a time. When a message is slow to process,
# other messages in the queue have to wait for it to complete. We artificially
# added slowness into our handler, but something like a database query or API
# call could cause this problem naturally.
def handle_in("slow_ping", _payload, socket) do
  Process.sleep(:rand.uniform(3000))
  {:reply, {:ok, %{ping: "pong"}}, socket}
end

# Phoenix provides a solution for the above slow_ping problem. We can respond
# in a separate process that executes in parallel with our Channel, meaning we
# can process all messages concurrently. We’ll use Phoenix’s socket_ref/1
# function to turn our Socket into a minimally represented format that can be
# passed around. Let’s make this change in our StatsChannel .
def handle_in("parallel_slow_ping", _payload, socket) do
  # The ref variable used by this function is a stripped-down version of the
  # socket . We pass a reference to the Socket around, rather than the full
  # thing, to avoid copying potentially large amounts of memory around the
  # application.
  ref = socket_ref(socket)

  # Task is used to get a Process up and running very quickly. In practice,
  # however, you'll probably be calling into a GenServer. You should always
  # pass the socket_ref to any function you call.
  Task.start_link(fn ->
    Process.sleep(:rand.uniform(3000))

    # We use Phoenix.Channel.reply/2 to send a response to the Socket. This
    # serializes the message into a reply and sends it to the Socket transport
    # process. Once this occurs, our client receives the response as if it came
    # directly from the Channel. The outside client has no idea that any of
    # this occurred.
    Phoenix.Channel.reply(ref, {:ok, %{ping: "pong"}})
  end)

  {:noreply, socket}
end
```

> You shouldn’t reach for reply/2 for all of your Channels right away. If you have
> a use case where a potentially slow database query is being called, or if you
> are leveraging an external API, then it’s a good fit. As with most things, there
> are benefits and trade-offs to using reply/2 . We have seen the benefit of increased
> parallelism already. A trade-off, though, is that we lose the ability to slow down
> a client (back-pressure) if it is asking too much of our system. We could write
> code to support a maximum amount of concurrency per Channel if needed.
> This would give us increased performance and ability to back-pressure, at a
> cost of increased complexity.

> Asynchronous Channel responses help to close a pitfall of accidentally limiting
> our Channel throughput. There is no silver bullet for writing code that is
> fully immune to these slowdowns. Keep an eye out for times when your code
> is going through a single process, whether it be a Channel or another process.

### Build a Scalable Data Pipeline

> Our real-time application keeps our users up to date with the latest information
> possible. This means we have to get data from our server to our clients,
> potentially a lot of data, as quickly and efficiently as possible. Delays or missed
> messages will cause users to not have the most current information in their
> display, affecting their experience. We must be intentional in designing how
> the data of our application flows due to the importance of this part of our sys-
> tem. The mechanism that handles outgoing real-time data is a data pipeline.

#### Traits of a Data Pipeline

> Our data pipeline should have a few traits no matter what technology we
> choose. Our pipeline can scale from both a performance and maintainability
> perspective when it exhibits these traits.
> 
> * **Deliver messages to all relevant clients**
> This means that a real-time event will be broadcast to all our connected
> Nodes in our data pipeline so they can handle the event for connected
> Channels. Phoenix PubSub handles this for us, but we must consider
> that our data pipeline spans multiple servers. We should never send
> incorrect data to a client.
>
> * **Fast data delivery**
> Our data pipeline should be as fast as possible. This allows a client to get
> the latest information immediately. Producers of data should also be able
> to trigger a push without worrying about performance.
>
> * **As durable as needed**
> Your use case might require that push events have strong guarantees of
> delivery, but your use case can also be more relaxed and allow for in-
> memory storage until the push occurs. In either case, you should be able
> to adjust the data pipeline for your needs, or even completely change it,
> in a way that doesn’t involve completely rewriting it.
> 
> * **As concurrent as needed**
> Our data pipeline should have limited concurrency so we don’t overwhelm
> our application. This is use-case dependent, as some applications are
> more likely to overwhelm different components of the system.
> 
> * **Measurable**
> It’s important that we know how long it takes to send data to clients. If
> it takes one minute to send real-time data, that reduces the application’s
> usability.

> These traits allow us to have more control over how our data pipeline operates,
> both for the happy path and failure scenarios. There has always been debate
> over the best technical solution for a data pipeline. A good solution for many
> use cases is a queue-based, GenStage-powered data pipeline. This pipeline
> exhibits the above traits while also being easy to configure.

#### GenStage Powered Pipeline

> GenStage helps us write a data pipeline that can exchange data from producers
> to consumers. GenStage is not an out-of-the-box data pipeline. Instead,
> it provides a specification on how to pass data, which we can then implement
> in our application's data pipeline.
>
> GenStage provides two main stage types that are used to model our pipeline:
> * **Producer** — Coordinates the fetching of data items and then passes to the
> next consumer stage. Producers can fetch data from a database, or they
> can keep it in memory. In this chapter, our data pipeline will be completely
> in memory.
> * **Consumer** — Asks for and receives data items from the previous producer
> stage. These items are then processed by our code before more items are
> received.

> We model our pipeline in a very sequential way. We start with a producer
> stage that is connected to a consumer stage. We could continue to link
> together as many stages as needed to model our particular data pipeline—a
> consumer can also be a producer to other consumers.

> GenStage will take the items we provide it (there could be several at once)
> and either sends them to waiting consumer stages or buffers them in memory.
> We are using GenStage’s internal buffer in our pipeline to hold and send data.
>
> This is a non-traditional use of GenStage, but allows us to have an item buffer
> while writing no buffering code of our own. This, combined with other features
> of GenStage that we’ll cover, gives us a lot of power for very little code.

> We add each stage to our application before our Endpoint boots. This is very
> important because we want our data pipeline to be available before our web
> endpoints are available. If we didn’t do this, we would sometimes see “no
> process” errors.

> The min/max demand option helps us configure our pipeline to only process
> a few items at a time. This should be configured to a low value for in-memory
> workloads. It is better to have higher values if using an external data store
> as this reduces the number of times we go to the external data store.

> You will immediately see a consumer message after the first push/1 call. Things
> get more interesting when we send many events to the producer in a short
> time period. The consumer starts by processing one item at a time. After ten
> are processed, the items are processed five at a time until the items are all
> processed.
>
> This pattern appears a bit unusual because we never see ten items processed
> at once, and we also see many single items processed. A GenStage consumer
> splits events into batches based on the max and min demand. Our values
> are ten and five, so the events are split into a max batch size of five. The single
> items are an implementation detail of how the batching works—this isn’t a
> big deal for a real application.
>
> For most use cases, you won’t need to worry about that internals of the
> buffering process. GenStage takes care of the entire process of managing the
> buffer and demand of consumers. You only need to think about writing data
> to the producer and the rest will be managed for you.

GenStage buffer will drop events after reaches the configure limit, therefore 
care needs to be taken to not produce more events then what consumers can process.
More details on [this post](https://elixirforum.com/t/genstage-producer-discarding-events/1943/3?u=exadra37) on the Elixir forum and in the [GenStage docs](https://hexdocs.pm/gen_stage/GenStage.html#module-buffering-demand).

#### Adding Concurrency and Channels

> A scalable data pipeline must handle multiple items at the same time; it must
> be concurrent. GenStage has a solution for adding concurrency to our pipeline
> with the ConsumerSupervisor module. This module allows us to focus on defining
> the pipeline and letting the library take care of how the concurrency will be
> managed.
>
> ConsumerSupervisor is a type of GenStage consumer that spawns a child process
> for each item received. The amount of concurrency is controlled via setup
> options, and it otherwise behaves exactly like a consumer. Every item spawns
> a new process; they’re not re-used, but this is cheap to do in Elixir.

> A quick note on concurrency versus parallelism. You make your system
> concurrent by creating processes that run work. The BEAM then makes that
> system parallel by taking the concurrent work and running it over multiple
> cores at the same time. All of the concern around how parallel execution
> happens is completely handled by the BEAM.

> You’ll see that the jobs run ten at a time with a delay in between. The items
> always group together the same way, but the group itself can come in any
> order. This is because our tasks are running fully parallel with each other
> and order is no longer guaranteed.
>
> In our earlier example, with a regular Consumer , the items were processed in
> batches of five. In this example, the items were processed ten at a time. The
> GenStage batch size hasn’t changed, but the ConsumerSupervisor is able to start
> up max_demand (ten) workers at a time. Each worker handles a single item, so
> the end result is that ten items are processed in parallel. You should tune
> the max_demand to the maximum amount of processes that you want to run in
> parallel, based on your use case.

> ConsumerSupervisor is very powerful. We added concurrent execution to our data
> pipeline in only a small amount of code, and most of it was boilerplate. This
> scales to a very large number of jobs with very little issue, thanks to the
> power of Elixir and the BEAM. One of the biggest advantages of how we added
> our concurrency is that the BEAM manages parallel execution of our work.
> **If we doubled our CPU cores, we’d double the execution parallelism of our**
> **pipeline.**

#### Measuring our Pipeline

> The ultimate question of running software is “how do I know it’s working?”
> Our data pipeline is no different. We need to be able to answer questions
> about the health of our pipeline so that we can fix any problems that occur.

> There are different ways to measure time in the BEAM, but we are using the 
> system time because a real-time app often runs across multiple servers. If we 
> used :erlang.monotonic_time/0, we would have drastically inaccurate timing
> information. However, there is some inaccuracy with system time as well 
> because two servers will often have slightly different times.

> We are using a histogram metric type to capture statistical information
> with our metric. Histograms aggregate several attributes of a given metric,
> such as percentiles, count, and sum. You will often use a histogram type
> when capturing a timing metric.

> There is one disclaimer for this measurement technique that is worth
> repeating: our data pipeline spans multiple servers, so the data could originate
> on a different server than where it finishes. Two servers usually have a slight
> amount of clock difference that would either add or remove milliseconds to
> the difference. In practice, we can accept this because the difference will
> usually be small, and we aren't basing application logic on the times.

#### Test our Data Pipeline

> There are a few different ways to approach the testing methodology for our
> pipeline. We could write unit tests for every part of the pipeline or integration
> tests for the entire pipeline. We’ll look at how to integration test our pipeline
> to see all pieces work together. This serves us well because we don’t have
> complex logic in our data pipeline. If we had more complex functions in our
> Worker , then we would most likely also want unit tests.

> We have to use a synchronous test, denoted by async: false , because our data 
> pipeline is globally available to the test suite. Using a synchronous test
> prevents random test failures.

> Testing doesn’t have to be complex to be powerful. This integration test doesn’t
> flex every nook and cranny of our data pipeline, but it covers close to all of
> it. Now that we have these tests, we would learn immediately if our pipeline
> became misconfigured.

#### The Power of GenStage

> Our applications must grow and adapt to changing requirements or lessons
> learned over time. We find ourselves in the best position when we can imple-
> ment new requirements by changing very little code. The power of GenStage
> is that it can grow with our application. We start simple and add as needed
> over time.

> Let’s look at a few examples of how our application may change over time.
> We’ll think about how GenStage can help us achieve these goals.
>
> ##### Enforce stricter delivery guarantees for messages
> One of the biggest trade-offs with a fully in-memory approach is that a
> server crash or restart will lose all current in-memory work. We can use
> a data store such as a SQL database, Redis, or Kafka to store every out-
> going message. This would reduce data loss potential when a server
> restarts. GenStage helps us here because its core purpose is to handle
> data requesting and buffering from external data stores. We could adapt
> our pipeline’s Producer module in order to read from the data store.
> You may get pretty far with an in-memory, no-persistence solution. There
> is a great saying in software architecture: “Our software architecture is
> judged by the decisions we are able to defer.” This means that you’re able
> to tackle the important things up-front and leave yourself open to tackle
> currently less important things in the future—such as pipeline persistence.
>
> ##### Augment an outgoing message with data from a database
> Our GenStage-powered pipeline exposes a Worker module that can do
> anything you want it to do. For example, it’s possible to augment messages
> with data from an external API or database. These external resources
> often have a maximum throughput, so the maximum concurrency option
> helps us to avoid overwhelming these external data providers. We could
> also leverage the concept of a GenStage ProducerConsumer to achieve the goal
> of data augmentation.
>
> ##### Equitable dispatching between users
> Our GenStage-based pipeline will currently send items on a first-come-
> first-served basis. This is great for most applications, but it could be
> problematic in an environment where a single user (or team of users) has
> significantly more messages than other users. In this scenario, all users
> would become slower due to the effect of a single user.

> GenStage allows us to write a custom Dispatcher module capable of routing
> messages in any way we want. We could leverage this to isolate users that
> are taking over the system’s capacity onto a single worker. We wouldn’t need
> to change any existing part of our application other than our Producer and
> Consumer modules.

> We don’t have to do any of these things until it’s the right time. We’re able to
> defer those decisions and focus on the behavior that is most important for now.
> GenStage is a great choice for writing a data pipeline. It’s efficient, well-designed
> with OTP principles, and easy to adapt to new requirements over time.
