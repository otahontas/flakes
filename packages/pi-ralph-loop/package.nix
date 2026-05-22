{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
}:

let
  versionData = lib.importJSON ./hashes.json;
  inherit (versionData) version sourceHash;
in
stdenvNoCC.mkDerivation {
  pname = "pi-ralph-loop";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/pi-ralph-loop/-/pi-ralph-loop-${version}.tgz";
    hash = sourceHash;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pi-ralph-loop
    cp -r * $out/lib/node_modules/pi-ralph-loop/

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    grep -q '"version": "${version}"' $out/lib/node_modules/pi-ralph-loop/package.json
  '';

  meta = with lib; {
    description = "Pi extension that reruns a prompt from a clean session checkpoint for bounded Ralph loops";
    homepage = "https://github.com/lnilluv/pi-ralph-loop";
    changelog = "https://github.com/lnilluv/pi-ralph-loop/releases";
    downloadPage = "https://www.npmjs.com/package/pi-ralph-loop";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    platforms = platforms.all;
  };
}
