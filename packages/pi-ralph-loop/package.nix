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
  pname = "pi-ralph-loop";
  version = data.version;

  src = fetchFromGitHub {
    owner = "lnilluv";
    repo = "pi-ralph-loop";
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
    test -f "$out/src/index.ts"
    test -f "$out/skills/ralph-loop/SKILL.md"
    test -f "$out/skills/ralph-draft/SKILL.md"
    test -f "$out/skills/ralph-finalize/SKILL.md"
  '';

  meta = with lib; {
    description = "Pi extension that reruns a prompt from a clean session checkpoint for bounded Ralph loops";
    homepage = "https://github.com/lnilluv/pi-ralph-loop";
    changelog = "https://github.com/lnilluv/pi-ralph-loop/releases";
    downloadPage = "https://www.npmjs.com/package/@lnilluv%2Fpi-ralph-loop";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    platforms = platforms.all;
  };
}
