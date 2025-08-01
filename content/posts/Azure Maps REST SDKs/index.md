---
title: "Azure Maps REST SDKs"
author: "Clemens Schotte"
date: 2022-11-02

tags: ["Azure", "Maps", "SDK", "REST", "Azure Maps"]
categories: ["Geospatial"]

resources:
- name: "featured-image"
  src: "featured-image.jpg"

draft: false
lightgallery: true
---

Azure Maps is more than just a Map on your website. It is a complete enterprise solution for location-aware solutions. For example, you can do (reverse) geocoding of customer addresses and use an isochrone to find out withs customers a close to your store or get weather conditions for all your past sales data to know withs products sell best by rain or hot weather or get the correct time-zone for your customer by translating an IP-address to a location and get the time-zone information, or you need to know what the travel time is between two or more locations. So many scenarios and use cases you can make location aware with Azure Maps.

You can call the [Azure Maps REST APIs](https://learn.microsoft.com/en-us/rest/api/maps/) directly from any programming language, which is not difficult but always needs extra work. With the introduction of the public preview Azure Maps REST SDKs for [C#](https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/maps) (.NET), [Java](https://github.com/Azure/azure-sdk-for-java/tree/main/sdk/maps), [Phyton](https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/maps), and [TypeScript](https://github.com/Azure/azure-sdk-for-js/tree/main/sdk/maps) (Node.js), you can earlier use the power of Azure Maps in your backend without the hassle of calling the APIs the correct way.

To give you a simple example in C#, we are searching for a Starbucks close to a customer's location in Seattle. Before we can begin, you need an Azure Maps key; see here [how to get a free Azure Maps key](https://aka.ms/AzureMapsGettingStarted).

The following code snippet creates a console program MapsDemo with .NET 8.0. You can use any [.NET standard 2.0-compatible](https://dotnet.microsoft.com/en-us/platform/dotnet-standard#versions) version as the framework.
 
```powershell
dotnet add package Azure.Maps.Search --prerelease
```

The following code snippet demonstrates how, in a simple console application, to import the `Azure.Maps.Search` package and perform a fuzzy search on “Starbucks” near Seattle. In the `Program.cs` file add the following code:

```csharp
using Azure; 
using Azure.Core.GeoJson; 
using Azure.Maps.Search; 
using Azure.Maps.Search.Models; 

// Use Azure Maps subscription key authentication 
var credential = new AzureKeyCredential("Azure_Maps_Subscription_key"); 
var client = new MapsSearchClient(credential); 

SearchAddressResult searchResult = client.FuzzySearch( 
    "Starbucks", new FuzzySearchOptions 
    { 
        Coordinates = new GeoPosition(-122.31, 47.61), 
        Language = SearchLanguage.EnglishUsa 
    }); 

// Print the search results 
foreach (var result in searchResult.Results) 
{ 
    Console.WriteLine($""" 
        * {result.PointOfInterest.Name} 
          {result.Address.StreetNumber} {result.Address.StreetName} 
          {result.Address.Municipality} {result.Address.CountryCode} {result.Address.PostalCode} 
          Coordinate: ({result.Position.Latitude:F4}, {result.Position.Longitude:F4}) 
        """); 
} 
```

In the above code snippet, you create a `MapsSearchClient` object using your Azure credentials, then use that Search Client's [FuzzySearch](https://learn.microsoft.com/en-us/dotnet/api/azure.maps.search.mapssearchclient.fuzzysearch) method passing in the point of interest (POI) name "Starbucks" and coordinates `GeoPosition(-122.31, 47.61)`. This all gets wrapped up by the SDK and sent to the Azure Maps REST endpoints. When the search results are returned, they're written out to the screen.

To run your application, go to the project folder and execute `dotnet run` in PowerShell.

More information you can read in the [Azure Maps REST SDK Developer Guide](https://learn.microsoft.com/en-us/azure/azure-maps/rest-sdk-developer-guide). Happy coding!

> This blog post was initially written by me for the [Azure Maps Tech Blog](https://blog.azuremaps.com).