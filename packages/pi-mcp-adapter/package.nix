{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
}:

let
  data = lib.importJSON ./hashes.json;
in
buildNpmPackage {
  pname = "pi-mcp-adapter";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/pi-mcp-adapter/-/pi-mcp-adapter-${data.version}.tgz";
    hash = data.sourceHash;
  };

  inherit nodejs;
  npmDepsHash = "";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  doInstallCheck = false;

  meta = with lib; {
    description = "MCP adapter for pi — discover, connect and manage MCP servers";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    changelog = "https://github.com/nicobailon/pi-mcp-adapter/releases";
    downloadPage = "https://www.npmjs.com/package/pi-mcp-adapter";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    mainProgram = "pi-mcp-adapter";
    platforms = platforms.all;
  };
}
