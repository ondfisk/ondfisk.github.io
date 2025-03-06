---
layout: post
title: Micro Frontends with Blazor WebAssembly
author: Rasmus Lystrøm
date: 2023-11-19 10:00:00 +0100
categories: blazor
permalink: micro-frontends-with-blazor-webassembly/
excerpt_separator: <!--more-->
type: blog
---

Recently one of my customers shared their challenges with sharing a large [Blazor](https://dotnet.microsoft.com/en-us/apps/aspnet/web-apps/blazor) [WebAssembly](https://developer.mozilla.org/en-US/docs/WebAssembly) app between multiple teams.

<!--more-->

## The problem

Basically, as with all kinds of monoliths, the monolithic frontend makes for a huge pain in merge conflicts and the like when multiple teams are trying to add features to the same code base.

Conceptually this can be illustrated like this:

![Monolithic Frontends](https://micro-frontends.org/ressources/diagrams/organisational/monolith-frontback-microservices.png "Monolithic Frontends")
*Monolithic Frontends*, source: [Micro Frontends](https://micro-frontends.org/)

## A solution

Conceptually we want to take the concept of end-to-end responsibility into the frontend by organizing into verticals as illustrated here:

![Organisation in Verticals](https://micro-frontends.org/ressources/diagrams/organisational/verticals-headline.png "Organisation in Verticals")
*Organisation in Verticals*, source: [Micro Frontends](https://micro-frontends.org/)

## The Blazor Proof of Concept

While the [Micro Frontends](https://micro-frontends.org/) make an excellent case for technology agnosticism the solution asked for centers around [Blazor](https://dotnet.microsoft.com/en-us/apps/aspnet/web-apps/blazor).

For simplicity the solution is built using only standard components where a little duplication of code is allowed for readability (#dry-is-over-rated) - i.e. there are no wonky build tasks like obscure copying of files and no use of reflection etc.

The PoC contains four repositories/solutions:

- [Downstream API](https://github.com/ondfisk/ComposableUI.DownstreamApi): Downstream API component
- [Component 1](https://github.com/ondfisk/ComposableUI.Component1): Example component (Counter)
- [Component 2](https://github.com/ondfisk/ComposableUI.Component1): Example component (Fetch data from downstream API)
- [Root](https://github.com/ondfisk/ComposableUI.Root): A composable root

### Downstream API

Vanilla [ASP.NET Core Minimal APIs](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis/overview) solution configured with [Microsoft Entra ID](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/azure-active-directory/) authentication.

### Component 1 and Component 2

Two components built with [Razor class library](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/ui-class) (RCL).

For each component all logic is contained in the RCL. A Blazor client app is supplied with it, which allows the component to be run and developed individually.

Each component is built and pushed to [GitHub Packages](https://github.com/features/packages).

For local testing a *Client* app is supplied.

### Root

This is the actual app. It contains *as little code as possible*.

This is a standard Blazor WebAssembly app which has been extended to use Component 1 and Component 2.

## Technical implementation

The *Root* contains technical details worth noting:

### Package handling

Add `nuget.config` to allow pulling packages from GitHub Packages.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <clear />
        <add key="nuget" value="https://api.nuget.org/v3/index.json" />
        <add key="github" value="https://nuget.pkg.github.com/NAMESPACE/index.json" />
    </packageSources>
    <packageSourceCredentials>
        <github>
            <add key="Username" value="USERNAME" />
            <add key="ClearTextPassword" value="TOKEN" />
        </github>
    </packageSourceCredentials>
</configuration>
```

Add the Component 1 and Component 2 packages to *Root*:

```bash
dotnet add package ComposableUI.Component1
dotnet add package ComposableUI.Component2
```

### Authentication

Helpers:

```csharp
public class DownstreamApiAuthorizationMessageHandler : AuthorizationMessageHandler
{
    public DownstreamApiAuthorizationMessageHandler(IAccessTokenProvider provider,
        NavigationManager navigation, IConfiguration config)
        : base(provider, navigation)
    {
        ConfigureHandler(
            authorizedUrls: [ config.GetSection("DownstreamApi")["BaseUrl"]! ],
            scopes: config.GetSection("DownstreamApi:Scopes").Get<List<string>>());
    }
}

public class DownstreamApiConfiguration
{
    public required Uri BaseUrl { get; init; }
    public required string[] Scopes { get; init; }
}
```

Modify `Program.cs`:

```csharp
var downstreamApi = builder.Configuration.GetSection("DownstreamApi").Get<DownstreamApiConfiguration>() ?? throw new InvalidOperationException("DownstreamApi configuration is missing");

builder.Services.AddScoped<DownstreamApiAuthorizationMessageHandler>();
builder.Services.AddHttpClient("ComposableUI.DownstreamApi", client => client.BaseAddress = downstreamApi.BaseUrl)
    .AddHttpMessageHandler<DownstreamApiAuthorizationMessageHandler>();

// Supply HttpClient instances that include access tokens when making requests to the server project
builder.Services.AddScoped(sp => sp.GetRequiredService<IHttpClientFactory>().CreateClient("ComposableUI.DownstreamApi"));

builder.Services.AddMsalAuthentication(options =>
{
    builder.Configuration.Bind("AzureAd", options.ProviderOptions.Authentication);
    foreach (var scope in downstreamApi.Scopes)
    {
        options.ProviderOptions.DefaultAccessTokenScopes.Add(scope);
    }
});
```

### Navigation and Routing

Add pages from Component 1 and Component 2 to `NavMenu.razor`:

```html
<div class="nav-item px-3">
    <NavLink class="nav-link" href="counter">
        <span class="oi oi-plus" aria-hidden="true"></span> Counter
    </NavLink>
</div>
<div class="nav-item px-3">
    <NavLink class="nav-link" href="fetchdata">
        <span class="oi oi-list-rich" aria-hidden="true"></span> Fetch data
    </NavLink>
</div>
```

Configure `App.razor` to check additional assemblies for routes (pages):

```html
<CascadingAuthenticationState>
    <Router AppAssembly="@typeof(App).Assembly" AdditionalAssemblies="[ typeof(ComposableUI.Component1.Root).Assembly, typeof(ComposableUI.Component2.Root).Assembly ]">
        ...
    </Router>
</CascadingAuthenticationState>
```

## Conclusion

I believe this concept can solve a number of issues with having multiple teams contributing to the same frontend, however, some changes are required in the *Root* from time to time:

- When adding a new component
- When adding a new page to navigation

Feel free to grab what you need from [GitHub](https://github.com/ondfisk/ComposableUI.Root).

Happy coding!

![Composable Root running locally](/assets/composable-root.png "Composable Root running locally")
*Composable Root running locally*
