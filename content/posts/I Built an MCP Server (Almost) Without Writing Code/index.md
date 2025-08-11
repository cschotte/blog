---
title: "I Built an MCP Server (Almost) Without Writing Code"
author: "Clemens Schotte"
date: 2025-08-11

tags: ["AI", "GitHub", "LLM", "Azure Maps", "MCP"]
categories: ["Programming"]

featuredImage: "featured-image.jpg"

draft: false

---

I’ve been watching **Model Context Protocol** (MCP) servers pop up everywhere as the glue between AI agents and the real world. The pitch is simple: expose tools and data through a standard protocol and suddenly your AI agents can plan trips, analyze documents, query databases, or in my case, work with maps. MCP clicked for me because it’s opinionated where it matters and unopinionated where it shouldn’t. It standardizes how clients and servers talk, but it doesn’t box you into a single stack. Think of it as the USB-C of AI integrations: one cable, many devices.  ￼ ￼

I’m a developer who lives in **Visual Studio Code** and ships on Azure. I wanted to see how far I could get by letting AI do the hands-on coding while I focused on architecture, constraints, and review. The goal was audacious but grounded: build a practical Azure Maps MCP server that exposes real geospatial capabilities as MCP tools, and get there largely by prompting. The result is live in a public repo if you want to skim or run it: [cschotte/azure-maps-mcp](https://github.com/cschotte/azure-maps-mcp).

What follows is the story of how I used **GitHub Copilot** in VS Code to go from a blank folder to a working MCP server backed by Azure Functions and the Azure Maps SDKs and REST APIs. I’ll walk through the prompts, the refactors, the architectural guardrails I put in, and the moments where the agent went off the rails and I had to step in.

## Why MCP + Azure Maps?

Maps make agents useful. Route planning, isochrones, reverse geocoding, POI search, static renders, time zones, weather, even IP-to-country, these are building blocks for real workflows. Azure Maps gives you all of that via .NET SDKs and REST. I wanted a server that exposes a curated, batteries-included set of tools that an LLM can call safely and consistently.  ￼

MCP gives me the language to describe those tools and a predictable way to call them from agentic clients. On the server side, I chose Azure Functions (isolated worker) so I could target modern .NET independently of the Functions host, wire up DI cleanly, and run everything locally with the Functions runtime while I iterate in VS Code.  ￼

## The “No-Code” Setup That Still Needs Engineering Judgment

I started with an empty folder in VS Code and asked Copilot Chat to scaffold an Azure Functions isolated worker project in C# targeting .NET 9. I was explicit about constraints: no in-process model, use DI, and keep the entrypoint minimal. Copilot generated `Program.cs`, a project with a Functions host, and a skeleton for configuration. I added a Services layer for Azure Maps, a Tools layer for the MCP endpoints, and a Common area for input validation, a small REST helper, and a uniform response envelope.

Copilot wrote the first pass of the `Program.cs`. I nudged it toward what I consider a healthy baseline: explicit logging, named `HttpClient` for REST calls, and a single place to bind the Azure Maps key from configuration (local dev reads from `local.settings.json`; production expects environment or Key Vault). The entrypoint ended up looking like this:

I asked Copilot to generate VS Code tasks so that **F5** would build and start the Functions host and attach the debugger. It created a build (functions) task and a `func: host start` task wired to the Azure Functions Core Tools. From there, local development was a single keypress. The repo’s [README](https://github.com/cschotte/azure-maps-mcp) shows the same flow if you want to reproduce it.  ￼

## Modeling the Tools the Way Agents Actually Use Them

I didn’t try to mirror every Azure Maps API. Instead, I curated a set that maps to common agent intents: find a place, reverse geocode and fetch boundaries, plan a route or compute an isochrone, fetch nearby POIs, render a static map, resolve an IP to a country, get a time zone, pull weather, and snap GPS points to roads. The server exposes these as discrete MCP tools with small, stable input shapes and predictable outputs.

Two early patterns mattered:

1.	A uniform response envelope. Every tool returns `{ success, meta, data }`. Lists use `{ query, items, summary }`; singletons use `{ query, result }`. This made it much easier to write prompts on the client side like “call location_find and show me the first item’s coordinates; if success is false, summarize the error.”
2.	Stringy booleans at the boundary. Some MCP clients bind function args as strings. I kept boolean-like inputs as "true"/"false" at the tool boundary, then normalized them to real booleans in the handlers. It’s a small accommodation that avoided brittle binding errors across clients.

For example, the **location_find** tool accepts a text query and an **includeBoundaries** flag. Under the hood it calls Azure Maps Search and, if requested, walks a fallback strategy for polygons (locality → postalCode → adminDistrict → countryRegion) because boundary availability varies by place and level. Azure Maps’ coverage nuances are real; your tool needs to be defensive.  ￼

## Where Copilot Shined

I used three Copilot experiences constantly:

**Ask mode** was my rubber duck and librarian. I’d drop a doc link to Azure Maps Time Zone or Weather and say “extract the minimal request/response we need and sketch a C# wrapper.” It would lift the right REST path, query parameters, and payload into a clean method. For SDK-backed APIs like Search or Routing, I asked it to show the equivalent with the .NET client. That cut my “find the right API and object model” time to minutes.  ￼

**Edit mode** let me refactor wide. When I noticed duplication in validation and HTTP error handling, I asked Copilot to “extract and centralize validation rules for lat/lon, radius, and ISO codes; make all tools use the same guard methods; return 400 with a consistent shape when validation fails.” It proposed diffs across multiple files, and I accepted them chunk by chunk.  ￼

**Agent mode** was my power tool for multi-step tasks, like turning three loosely similar tool handlers into a single **navigation_calculate** that handles directions, matrix, and range (isochrone) flows with a `calculationType` discriminator. It iterated on compiler errors and mismatched types until it ran. I still reviewed the final diff like a hawk, but this mode saved hours.  ￼

Copilot inevitably over-codes if you let it. It suggested extra abstractions I didn’t need and occasionally “fixed” something another model wrote by undoing it. I kept it on task with narrow prompts, frequent test runs, and a willingness to say “back up two commits and try a smaller step.” The more precise and isolated the task, the better the result.

## Clean Inputs, Predictable Outputs

Each Function exposes one MCP tool via a simple HTTP trigger. Instead of binding directly to arbitrary JSON, I had Copilot generate specific request models with explicit types and validation attributes, then a controller-style handler that calls the service and wraps the result in the uniform envelope.

One subtle but important lesson: when you design for LLMs, error shapes matter. I made Copilot implement a small error type with a code, a friendly message, and a details bag. It turned cryptic HTTP exceptions into actionable feedback an agent can reason about.

## Copilot for the “Glue Work”

The time savings weren’t just in code. I used AI smart actions in VS Code to generate commit messages that accurately summarized multi-file changes, then tweaked intent in a sentence or two. For README work, I pasted code and asked Copilot to explain usage tersely and to propose a clear “Build and Run” section. It also generated the local tasks.json pipeline that lets me run the Functions host with one command. These things used to be procrastination traps; now they’re minutes.  ￼

## What Went Sideways

Letting the agent roam is seductive. I tried one broad prompt “consolidate the three navigation handlers into a single tool with a discriminator; add docs and tests” and watched complexity creep in. The model introduced extra layers and re-named DTOs mid-diff. I aborted, rewrote the prompt into three atomic tasks, and the result was clean.

Model hopping also caused “helpful undo” moments. One model preferred slightly different DTO names and dutifully refactored usages, breaking earlier code. My rule now: pick one model per task, keep the diff small, and run the host between steps. Copilot is powerful, but you remain the engineer of record.

## Lessons I’m Taking Forward

Agentic tooling is finally good enough to feel like a teammate. The biggest unlock wasn’t that Copilot wrote code; it was that it kept context across the repo, docs, diffs, and terminal output, and it could operate in different modes tailored to what I needed, **ask**, **edit**, or **act**. The trick is to design like a senior engineer and prompt like one: define constraints, choose simple interfaces, keep tasks small, and insist on clear error stories. Copilot will happily pour concrete, but you still have to draw the blueprint.  ￼

On the product side, MCP is a pragmatic standard that lets me expose Azure Maps safely to any MCP-aware client without yet another bespoke integration. It’s early days, but the “USB-C for AI apps” metaphor is earning its keep.  ￼
