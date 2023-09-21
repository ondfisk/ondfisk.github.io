---
layout: post
title: "Micro Frontends with Blazor WebAssembly"
date: 2023-09-21 20:00:00 +0200
categories: blazor micro-frontends micro-services webassembly
permalink: micro-frontends-with-blazor-webassembly/
---

## Introduction

Recently one of my customers shared their challenges with sharing a large [Blazor](https://dotnet.microsoft.com/en-us/apps/aspnet/web-apps/blazor) [WebAssembly](https://developer.mozilla.org/en-US/docs/WebAssembly) app between multiple teams.

## The problem

Basically, as with all kinds of monoliths, the monolithic frontend makes for a huge pain in merge conflicts and the like when multiple teams are trying to add features to the same code base.

Conceptually this can be illustrated like this:

![Monolithic Frontends](https://micro-frontends.org/ressources/diagrams/organisational/monolith-frontback-microservices.png "Monolithic Frontends")
*Monolithic Frontends*, source: [Micro Frontends](https://micro-frontends.org/)

## The solution

Conceptually we want to take the concept of end-to-end reposibility into the frontend by organizing into verticals as illustrated here:

![Organisation in Verticals](https://micro-frontends.org/ressources/diagrams/organisational/verticals-headline.png "Organisation in Verticals")
*Organisation in Verticals*, source: [Micro Frontends](https://micro-frontends.org/)

## The Blazor Proof of Concept

While the [Micro Frontends](https://micro-frontends.org/) make an excellent case for technology agnosticism the solution asked for centers around [Blazor](https://dotnet.microsoft.com/en-us/apps/aspnet/web-apps/blazor).

The PoC contains four repositories/solutions:

- [Downstream API](https://github.com/ondfisk/ComposableUI.DownstreamApi): Downstream API component
- [Component 1](https://github.com/ondfisk/ComposableUI.Component1): Example component (Counter)
- [Component 2](https://github.com/ondfisk/ComposableUI.Component1): Example component (Fetch data from downstream API)
- [Root](https://github.com/ondfisk/ComposableUI.Root): A composable root

### Downstream API

Vanilla [ASP.NET Core Minimal APIs](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis/overview) solution configured with [Microsoft Entra ID](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/azure-active-directory/) authentication.

### Component 1 and 2

Two components built with [Razor class library](https://learn.microsoft.com/en-us/aspnet/core/razor-pages/ui-class) (RCL).

For each component all logic is contained in the RCL. A Blazor client app is supplied with it, which allows the component to be run and developed individually.

Each component is built and pushed to [GitHub Packages](https://github.com/features/packages)

### Root

Composable root. This is the actual app. It contains *as little code as possible*