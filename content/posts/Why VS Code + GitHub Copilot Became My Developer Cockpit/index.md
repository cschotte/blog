---
title: "Why VS Code + GitHub Copilot Became My Developer Cockpit"
author: "Clemens Schotte"
date: 2025-07-29

tags: ["AI", "GitHub", "Copilot", "VSCode"]
categories: ["Programming"]

featuredImage: "featured-image.jpg"

draft: false

---

The first time I connected Visual Studio Code with GitHub Copilot, I expected party tricks. I got something closer to a new way of working. It wasn’t that code appeared by magic. It was that the little frictions, like the boilerplate, the glue code, the tests I knew I should write but kept postponing, stopped dominating my day. VS Code had already been my editor of choice for its ergonomics and extensibility; Copilot turned that editor into a cockpit where intention became motion. This post is my field report: what I actually run, how I prompt, where it saves time, and where I still slow down and think.

## What I ask from an IDE

My week crosses C# backends on .NET, Rust services and CLIs, and the occasional Zig utility when I want to get close to the metal. I need a place where navigation doesn’t melt under solutions and workspaces, where debugging is first-class for CoreCLR and native processes, where analyzers and formatters keep me honest, where I can orchestrate repeatable tasks without a pile of shell glue, and where a brand-new contributor can open the project and be productive in minutes. VS Code hits those marks out of the box; the difference after adding Copilot is that the hand-offs, like authoring tests, drafting docs, sketching refactors, writing commit messages, start to feel like a single continuous motion instead of separate chores.

## What I think about Copilot

Copilot is, for me, a drafting engine with context awareness. It reads what I’m doing in the editor and offers the most likely next move. I don’t treat it as an oracle. I treat it like a sharp junior engineer who has seen a million repositories and never gets tired of typing. If my intent is vague, its suggestions are vague; if my intent is precise, its drafts become eerily on target. When I’m unsure where I’m going, I sketch types or tests first, then let Copilot fill the empty spaces. When correctness matters, I keep my hands on the wheel, review everything, and tighten the specs.

## The setup I actually use

I keep VS Code lean but deliberate. **Copilot** and **Copilot Chat** are installed and enabled. For C#, the [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit) and the official [C# extension](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp) give me language services, Roslyn analyzers, and a one-keystroke test runner. For Rust, [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) and [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) give me the right balance of hints and stepping power; for Zig, the [Zig extension](https://marketplace.visualstudio.com/items?itemName=ziglang.vscode-zig) keep the feedback loop tight. I treat VS Code’s tasks and launch configurations as part of the codebase because “press F5 and go” is culture, not an accident.

## Prompts that pull their weight

The prompts that consistently work are specific, grounded in the files that are open, and framed with constraints. I’ll say, “Given CsvToNdjson.cs, rewrite the parser to avoid allocations using spans; keep the public signature, add tests for malformed rows.” Or, “In src/main.rs, add Serde models and stream CSV to NDJSON with proper error handling; no panics; propose a minimal diff.” If I’m refactoring, I’ll ask for a before/after with a rule like “no side effects; inject I/O; keep pure functions testable.” When a test fails, I paste the stack trace and ask for an explanation and a minimal patch that doesn’t change the public API. The more I emphasize small functions, exhaustive types, and early returns, the more the drafts read like my code instead of generic code.

## Examples

I like examples that stand up in production. A simple but representative task is a streaming transform that reads a large CSV, converts amounts, and writes NDJSON (It’s a format where each line is a separate JSON object). It’s the kind of thing with a right answer but lots of ceremony.

### C#

I want this to run in constant memory, avoid unnecessary allocations, and write one JSON object per line. I’ll keep the parser simple and deterministic and use `System.Threading.Channels` to bound the pipeline so one slow stage does not drown the rest.

```csharp
// src/CsvToNdjson.cs
using System.Buffers.Text;
using System.Text;
using System.Text.Json;
using System.Threading.Channels;

public static class CsvToNdjson
{
    public record InputRow(string Id, int AmountCents, string Currency)
    {
        public bool IsHighValue(int threshold) => AmountCents >= threshold;
    }

    public static async Task ConvertAsync(
        string csvPath,
        string outPath,
        int threshold = 50_000,
        CancellationToken ct = default)
    {
        var channel = Channel.CreateBounded<InputRow>(new BoundedChannelOptions(8192)
        {
            SingleReader = true,
            SingleWriter = true,
            FullMode = BoundedChannelFullMode.Wait
        });

        var producer = Task.Run(async () =>
        {
            await using var fs = File.OpenRead(csvPath);
            using var sr = new StreamReader(fs, Encoding.UTF8, detectEncodingFromByteOrderMarks: true, bufferSize: 1 << 16);
            string? header = await sr.ReadLineAsync();
            if (header is null) return;

            while (!sr.EndOfStream)
            {
                ct.ThrowIfCancellationRequested();
                var line = await sr.ReadLineAsync();
                if (string.IsNullOrWhiteSpace(line)) continue;

                // naive split; swap with a CSV reader if your data contains quoted commas
                var parts = line.Split(',');
                if (parts.Length < 3) continue;

                if (!int.TryParse(parts[1], out var amount)) continue;
                var row = new InputRow(parts[0], amount, parts[2]);
                await channel.Writer.WriteAsync(row, ct);
            }

            channel.Writer.Complete();
        }, ct);

        await using var outStream = File.Create(outPath);
        await foreach (var row in channel.Reader.ReadAllAsync(ct))
        {
            var json = JsonSerializer.Serialize(new
            {
                id = row.Id,
                amountCents = row.AmountCents,
                currency = row.Currency,
                isHighValue = row.IsHighValue(threshold)
            });

            var bytes = Encoding.UTF8.GetBytes(json);
            await outStream.WriteAsync(bytes, ct);
            await outStream.WriteAsync(new byte[] { (byte)'\n' }, ct);
        }

        await producer;
    }
}
```

I like my tests to be small and expressive. [xUnit](https://xunit.net/) gives me exactly that, and Copilot happily drafts the first pass that I then tighten.

```csharp
// tests/CsvToNdjsonTests.cs
using System.IO;
using System.Text;
using Xunit;

public class CsvToNdjsonTests
{
    [Fact]
    public async Task Converts_And_Flags_High_Value()
    {
        var csv = "id,amount,currency\nA,50000,EUR\nB,49999,USD\n";
        var tmpCsv = Path.GetTempFileName();
        var tmpOut = Path.GetTempFileName();
        await File.WriteAllTextAsync(tmpCsv, csv, Encoding.UTF8);

        await CsvToNdjson.ConvertAsync(tmpCsv, tmpOut, threshold: 50_000);

        var lines = await File.ReadAllLinesAsync(tmpOut, Encoding.UTF8);
        Assert.Contains("\"isHighValue\":true", lines[0]);
        Assert.Contains("\"isHighValue\":false", lines[1]);
    }
}
```

For debugging, I keep a simple `launch.json` so hitting F5 under CoreCLR does the right thing, with symbols ready and just-my-code enabled.

```json
// .vscode/launch.json (excerpt)
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Launch",
      "type": "coreclr",
      "request": "launch",
      "program": "${workspaceFolder}/bin/Debug/net9.0/YourApp.dll",
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal",
      "justMyCode": true
    }
  ]
}
```

I also let Copilot draft analyzers and ruleset updates when a pattern repeats in reviews; it won’t replace human judgment, but it saves me from rewriting the same diagnostic boilerplate.

### Rust

[Rust](https://www.rust-lang.org) is where I go when I want sharp edges and strong guarantees. I still keep I/O injectable and avoid panics for expected errors. Copilot is good at filling out the pattern once I’ve defined the types and the contract.

```toml
# Cargo.toml (excerpt)
[package]
name = "csv_ndjson"
version = "0.1.0"
edition = "2021"

[dependencies]
csv = "1"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
thiserror = "1"
```

```rust
// src/main.rs
use csv::StringRecord;
use serde::Serialize;
use std::{fs::File, io::Write, path::PathBuf};
use thiserror::Error;

#[derive(Debug, Error)]
enum AppError {
    #[error("io: {0}")]
    Io(#[from] std::io::Error),
    #[error("csv: {0}")]
    Csv(#[from] csv::Error),
    #[error("invalid row: {0}")]
    Invalid(String),
}

#[derive(Serialize, Debug)]
struct OutRow {
    id: String,
    amount_cents: u64,
    currency: String,
    is_high_value: bool,
}

fn map_record(rec: &StringRecord, threshold: u64) -> Result<OutRow, AppError> {
    let id = rec.get(0).ok_or_else(|| AppError::Invalid("missing id".into()))?;
    let amount_str = rec.get(1).ok_or_else(|| AppError::Invalid("missing amount".into()))?;
    let currency = rec.get(2).ok_or_else(|| AppError::Invalid("missing currency".into()))?;

    let amount_cents: u64 = amount_str.parse().map_err(|_| AppError::Invalid("bad amount".into()))?;
    Ok(OutRow {
        id: id.to_string(),
        amount_cents,
        currency: currency.to_string(),
        is_high_value: amount_cents >= threshold,
    })
}

fn run(input: PathBuf, output: PathBuf, threshold: u64) -> Result<(), AppError> {
    let mut rdr = csv::Reader::from_path(input)?;
    let mut out = File::create(output)?;

    for result in rdr.records() {
        let rec = result?;
        let row = map_record(&rec, threshold)?;
        // let json = serde_json::to_string(&row).expect("serialize");
        let json = serde_json::to_string(&row)?;
        writeln!(out, "{json}")?;
    }
    Ok(())
}

fn main() -> Result<(), AppError> {
    // hardcode paths for brevity; wire clap/argp in real life
    run("input.csv".into(), "out.json".into(), 50_000)
}
```

And the test that keeps me honest lives right next to it. Copilot will generate something close to this once it sees the function signature; I always tighten the assertions and add failure cases.

```rust
// src/lib.rs (optional if you split logic for testing)
// tests/transform.rs
#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::NamedTempFile;

    #[test]
    fn flags_high_value_correctly() {
        let mut csv = NamedTempFile::new().unwrap();
        writeln!(csv, "id,amount,currency").unwrap();
        writeln!(csv, "A,50000,EUR").unwrap();
        writeln!(csv, "B,49999,USD").unwrap();

        let out = NamedTempFile::new().unwrap();

        run(csv.path().into(), out.path().into(), 50_000).unwrap();

        let content = std::fs::read_to_string(out.path()).unwrap();
        let lines: Vec<_> = content.lines().collect();
        assert!(lines[0].contains("\"is_high_value\":true"));
        assert!(lines[1].contains("\"is_high_value\":false"));
    }
}
```

For stepping through Rust, CodeLLDB in VS Code remains my default. I keep a launch configuration that points at the produced binary so I don’t think about paths while I’m thinking about state.

```json
// .vscode/launch.json (rust excerpt)
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Rust binary",
      "type": "lldb",
      "request": "launch",
      "program": "${workspaceFolder}/target/debug/csv_ndjson",
      "args": [],
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

### Zig

[Zig](https://ziglang.org) is refreshing when I want predictable performance and explicit control. Copilot is still helpful for the scaffolding, but I rely on the standard library for the important parts and keep errors explicit.

```zig
// src/main.zig
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = std.process.args();
    _ = try args.next(); // program name
    const in_path = args.next() orelse "input.csv";
    const out_path = args.next() orelse "out.json";

    const threshold: u64 = 50_000;

    var infile = try std.fs.cwd().openFile(in_path, .{ .read = true });
    defer infile.close();
    var outfile = try std.fs.cwd().createFile(out_path, .{ .write = true, .truncate = true });
    defer outfile.close();

    var br = std.io.bufferedReader(infile.reader());
    var in_stream = br.reader();

    var line_buf = std.ArrayList(u8).init(allocator);
    defer line_buf.deinit();

    // read header
    _ = try readLineAlloc(in_stream, &line_buf);

    while (try readLineAlloc(in_stream, &line_buf)) |line| {
        var it = std.mem.split(u8, line, ",");
        const id = it.next() orelse continue;
        const amount_s = it.next() orelse continue;
        const currency = it.next() orelse continue;

        const amount = try std.fmt.parseInt(u64, amount_s, 10);
        const is_high = amount >= threshold;

        try outfile.writer().print(
            "{{\"id\":\"{s}\",\"amountCents\":{d},\"currency\":\"{s}\",\"isHighValue\":{s}}}\n",
            .{ id, amount, currency, if (is_high) "true" else "false" },
        );
    }
}

fn readLineAlloc(reader: anytype, buf: *std.ArrayList(u8)) !?[]u8 {
    buf.clearRetainingCapacity();
    var stream = reader;
    const nl: u8 = '\n';

    while (true) {
        var byte: [1]u8 = undefined;
        const n = try stream.read(byte[0..]);
        if (n == 0) break;
        if (byte[0] == nl) break;
        try buf.append(byte[0]);
    }
    if (buf.items.len == 0) return null;
    return buf.items;
}
```

Zig’s test blocks live right next to the code. I’ll often write a tiny line-split test to pin behavior before letting Copilot fill the pattern everywhere else.

```zig
test "parse int safely" {
    const parsed = try std.fmt.parseInt(u64, "50000", 10);
    try std.testing.expectEqual(@as(u64, 50000), parsed);
}
```

## Debugging with AI in the loop

Debugging is where the integration matters most. I run tests or start the program under the debugger, capture the failing stack trace, and paste it into Copilot Chat with a request to explain what happened and propose a minimal fix that avoids changing public APIs. Because the code and errors are already open in the editor, the back-and-forth stays grounded. Conditional breakpoints and logpoints are my default because they don’t require code changes, and I keep a handful of watch expressions to track the objects that tend to go sideways. In .NET, I keep symbol loading fast and source link enabled; in Rust and Zig, I let CodeLLDB or the C/C++ debugger step through optimized builds when I’m chasing heisenbugs.

## Exercising APIs and wiring CI

I like having an `api.http` file that hits real endpoints during development. It doubles as documentation you can execute, and Copilot is surprisingly good at filling in token flows and error cases once it sees the pattern. On the CI side, I let Copilot draft a minimal pipeline—dotnet test with caches for NuGet, cargo test with a sensible Rust toolchain matrix, and a simple Zig build—then I tune it to fit the project’s real constraints. The speed-up is not in writing YAML I could write myself; it’s in not context-switching away from the code that actually matters.

## Pull requests, reviews, and change management

A good pull request is a story with a beginning, middle, and end. Inside VS Code, I use the GitHub Pull Requests extension to live inside that story, and I ask Copilot to help with the narrative parts. It will summarize a diff, call out potential risks, and suggest missing tests; it will also draft a conventional commit message with a “Why” section that I can edit down to the truth. The point isn’t to outsource judgment. It’s to spend judgment on design and correctness instead of on verb forms and checklists.

## Closing thoughts

VS Code without Copilot is a great editor. VS Code with Copilot is, for me, a force multiplier that shortens the path between intention and impact. The magic isn’t that it “writes code for you.” The magic is that the editor becomes a place where you can describe what you mean in the language of your project, and the ceremony melts away. If you try this stack, start small: pick a real task, state your intent as precisely as you can, and let the assistant draft the parts that don’t deserve creative energy. Keep the parts that do.
