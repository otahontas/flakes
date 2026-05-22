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
  pname = "pi-web-access";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/pi-web-access/-/pi-web-access-${data.version}.tgz";
    hash = data.sourceHash;
  };

  inherit nodejs;
  npmDepsHash = "";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  doInstallCheck = false;

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
