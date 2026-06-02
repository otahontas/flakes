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
  pname = "pi-subagents";
  version = data.version;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
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
    test -f "$out/src/extension/index.ts"
    test -d "$out/skills"
    test -d "$out/prompts"
  '';

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
