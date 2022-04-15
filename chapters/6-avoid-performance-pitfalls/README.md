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
