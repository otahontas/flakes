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
  pname = "pi-subagents";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/pi-subagents/-/pi-subagents-${data.version}.tgz";
    hash = data.sourceHash;
  };

  inherit nodejs;
  npmDepsHash = "";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  doInstallCheck = false;

  meta = with lib; {
    description = "Subagent orchestration for pi — delegate tasks to specialized coding agents";
    homepage = "https://github.com/nicobailon/pi-subagents";
    changelog = "https://github.com/nicobailon/pi-subagents/releases";
    downloadPage = "https://www.npmjs.com/package/pi-subagents";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    mainProgram = "pi-subagents";
    platforms = platforms.all;
  };
}
