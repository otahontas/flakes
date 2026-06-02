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
  pname = "pi-web-access";
  version = data.version;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
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
    test -f "$out/skills/librarian/SKILL.md"
  '';

  meta = with lib; {
    description = "Web access extension for pi — search, fetch, and extract web content";
    homepage = "https://github.com/nicobailon/pi-web-access";
    changelog = "https://github.com/nicobailon/pi-web-access/releases";
    downloadPage = "https://www.npmjs.com/package/pi-web-access";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    platforms = platforms.all;
  };
}
