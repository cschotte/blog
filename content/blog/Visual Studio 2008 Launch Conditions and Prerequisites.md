---
title: "Visual Studio 2008 Launch Conditions and Prerequisites"
date: 2007-08-15
draft: false
tags: ["Visual Studio"]
---

If you are creating a Setup Project in Visual Studio 2008 to deploy your amazing new application, you need to set which version of the .NET Framework you are targeting. If your application is developed for .NET 2.0 you need to tell the Setup Project to check the target machine for the .NET 2.0 Framework. By default, the Setup project will check for .NET 3.5 (in VS2008) even if your application is targeting .NET 2.0.

First, you need to set the Prerequisites the Setup Project will install to the target machine (if it is not installed already). This can be done by the Properties windows of the Setup Project.

![Visual Studio 2008 Prerequisites](/media/VS2008_Prerequisites.png)

Then you need to tell the Setup Project which launch conditions you need for the .NET Framework.

![Visual Studio 2008 Solution Explorer](/media/VS2008_SolutionExplorer.png)

This Setup Project will now check the target machine for the .NET 2.0 Framework instead of the .NET 3.5 Framework.

![Visual Studio 2008 Launch Condition Properties](/media/VS2008_LaunchConditionProperties.png)