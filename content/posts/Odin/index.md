---
title: "Fixing Odin and Raylib on macOS: The Git LFS Problem"
description: "While rewriting my old C game CaveRace in Odin, Raylib appeared to be missing. The real problem was an incomplete Git checkout caused by Git LFS."
author: "Clemens Schotte"
date: 2026-07-16

tags: ["Odin", "raylib", "Git LFS", "macOS", "VSCode", "Game Development"]
categories: ["Programming"]

featuredImage: "featured-image.png"

draft: false
---

I recently started rewriting [CaveRace](https://caverace.com/1/), a game I originally built in C in 1997. The old version was written for MS-DOS using Borland C, VGA Mode 13h graphics, and a little x86 assembly. Rewriting it is a good excuse to revisit the game and experiment with a modern systems programming language.

For this version, I chose [Odin](https://odin-lang.org/) together with [Raylib](https://www.raylib.com/). Odin feels familiar when coming from C, and its official `vendor` collection already includes Raylib bindings and native libraries. In theory, getting a window on the screen should be as simple as importing Raylib:

```odin
import rl "vendor:raylib"
```

Instead, Odin told me that the package did not exist:

```text
Syntax Error: Path does not exist: vendor:raylib
```

At first, this looked like a Raylib installation problem. It was not. The real problem was Git.

## A working compiler with a missing library

My first Odin installation looked mostly correct. The `odin` command worked, and the `base` and `core` collections were available. However, the `vendor` directory contained only a few libraries and `vendor/raylib` was missing completely.

That was confusing because Raylib is included in the [official Odin repository](https://github.com/odin-lang/Odin/tree/master/vendor/raylib). There is no separate Odin package to install, and installing another copy of Raylib with Homebrew does not fix a missing `vendor:raylib` import.

The clue was hidden earlier in the terminal output from `git clone`:

```text
git-lfs filter-process: git-lfs: command not found
fatal: the remote end hung up unexpectedly
warning: Clone succeeded, but checkout failed.
```

That last line explains the strange state of the installation. Git had created the repository and downloaded its history, but it had not completed the working-tree checkout.

## Why Git LFS matters here

[Git Large File Storage](https://git-lfs.com/) keeps large binary files outside the normal Git object database and places small pointer files in the repository. Odin uses Git LFS for several prebuilt vendor libraries, including the Raylib libraries for macOS.

I had cloned Odin before installing Git LFS. When Git reached one of those files, it could not run the LFS filter and stopped the checkout. Enough files were present to make the Odin folder look plausible, but the installation was incomplete.

This is why the error was easy to misdiagnose:

- Odin itself appeared to work.
- The error mentioned Raylib, not Git LFS.
- The clone existed on disk.
- Only part of the `vendor` collection was available.

The important message was not that the clone had succeeded. It was that the checkout had failed.

## Repairing the existing Odin clone

There is no need to download everything again. First, install and initialize Git LFS:

```sh
brew install git-lfs
git lfs install
```

The second command normally only has to be run once for a macOS user account.

Next, return to the existing Odin repository and complete the checkout:

```sh
cd ~/Odin
git restore --source=HEAD --worktree .
git lfs pull
```

Now build the compiler again:

```sh
make release-native
```

Finally, check that both the Odin binding and the native macOS library are present.

## A clean installation on macOS

If you have not installed Odin yet, installing Git LFS before cloning avoids the problem entirely. The following is the complete setup I used on macOS.

Install Apple's command-line development tools:

```sh
xcode-select --install
```

Install [Homebrew](https://brew.sh/) if it is not already available, then install LLVM and Git LFS:

```sh
brew install llvm
brew install git-lfs
git lfs install
```

Clone and build Odin:

```sh
git clone https://github.com/odin-lang/Odin.git ~/Odin
cd ~/Odin
make release-native
```

This follows the [official Odin source-build instructions for macOS](https://odin-lang.org/docs/install/). The current instructions support both Apple Silicon and Intel Macs.

Add Odin to the Zsh path so the compiler can be used from any project:

```sh
echo 'export PATH="$HOME/Odin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

The location is important. By default, the `odin` executable expects to be next to the `base`, `core`, and `vendor` directories. Keeping the compiler in `~/Odin` and adding that directory to `PATH` preserves this layout.

Verify the result:

```sh
odin version
odin root
ls ~/Odin/vendor/raylib
```

The Raylib directory should contain files such as `raylib.odin`, `raymath.odin`, `raygui.odin`, and the `macos` directory with its native libraries.

## Testing Odin with Raylib

Before returning to CaveRace, I used a small program to prove that the compiler, binding, and native library all worked together. Create a new directory with a `main.odin` file:

```odin
package game

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "Odin and Raylib")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("Odin and Raylib are working!", 190, 200, 20, rl.DARKGRAY)
		rl.EndDrawing()
	}
}
```

First, check the package without creating an executable:

```sh
odin check .
```

Then build and run it:

```sh
odin run .
```

If a window appears with the message, the entire toolchain is working. The `vendor:raylib` import resolves against the `vendor` directory in the Odin installation, not a directory inside the game project.

## Debugging CaveRace in Visual Studio Code

Once the command-line build worked, I wanted the normal F5 debugging workflow in Visual Studio Code. I installed two extensions:

1. [Odin Language](https://marketplace.visualstudio.com/items?itemName=DanielGavin.ols) for syntax highlighting, completion, diagnostics, formatting, and navigation through OLS.
2. [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) for debugging the native executable produced by Odin.

VS Code needs one configuration to build CaveRace and another to launch the resulting executable with LLDB.

### Build the debug executable

Create `.vscode/tasks.json` in the CaveRace project:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "odin: prepare build directory",
            "type": "process",
            "command": "/bin/mkdir",
            "args": [
                "-p",
                "${workspaceFolder}/build"
            ],
            "problemMatcher": []
        },
        {
            "label": "odin: build debug",
            "type": "process",
            "command": "odin",
            "args": [
                "build",
                ".",
                "-debug",
                "-out:${workspaceFolder}/build/caverace"
            ],
            "options": {
                "cwd": "${workspaceFolder}"
            },
            "dependsOn": "odin: prepare build directory",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": []
        }
    ]
}
```

The `-debug` flag adds debug information and sets Odin's built-in `ODIN_DEBUG` constant to `true`. The output path must match the path used by the debugger.

### Launch the game with LLDB

Create `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug CaveRace",
            "type": "lldb",
            "request": "launch",
            "program": "${workspaceFolder}/build/caverace",
            "cwd": "${workspaceFolder}",
            "preLaunchTask": "odin: build debug",
            "terminal": "integrated",
            "stopOnEntry": false
        }
    ]
}
```

The important connection is `preLaunchTask`. Pressing F5 first runs the debug build and then launches exactly the executable created by that task. Breakpoints in the Odin source can now be used like they are in my other native projects.

Because Raylib opens its own application window, CaveRace runs in a separate window while program output and debugger information remain visible in VS Code.

Generated executables do not belong in source control, so I also added the build directory to `.gitignore`:

```gitignore
build/
```

## The actual fix was earlier in the process

After repairing the clone, no separate Raylib installation or custom linker setup was necessary. Odin already contained everything I needed. The failure happened one step earlier: Git could not finish checking out the repository because Git LFS was missing.

That is the useful lesson from this problem. When a freshly cloned repository is missing files, do not only inspect the build error. Scroll back and verify that Git completed the checkout. A repository directory on disk does not necessarily mean that the working tree is complete.

With Git LFS installed, Odin rebuilt successfully, `vendor:raylib` resolved, the test window opened, and F5 launched CaveRace under LLDB. I could finally stop debugging the installation and start rewriting the game.
