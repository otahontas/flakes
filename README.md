# Pi flakes

Nix packages for Pi extensions.

## Use from another flake

```nix
inputs.pi-flakes.url = "github:otahontas/flakes";

# then use:
pi-flakes.packages.${system}.pi-mcp-adapter
pi-flakes.packages.${system}.pi-web-access
pi-flakes.packages.${system}.pi-subagents
pi-flakes.packages.${system}.pi-ralph-loop
```

Each package builds to a Pi package root. Home Manager can symlink the derivation output directly into `~/.pi/agent/extensions/<package>`.
