{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
}:

let
  data = lib.importJSON ./hashes.json;
in
buildNpmPackage {
  pname = "pi-mcp-adapter";
  version = data.version;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    rev = "v${data.version}";
    hash = data.sourceHash;
  };

  inherit nodejs;
  npmDepsHash = data.npmDepsHash;
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  postPatch = lib.optionalString (builtins.pathExists ./package-lock.json) ''
    cp ${./package-lock.json} package-lock.json
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r . "$out/"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    test -f "$out/package.json"
    test -f "$out/index.ts"
  '';

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
