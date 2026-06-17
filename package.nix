{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.6.1";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-57hRfpVd4I08GagayS8MaF5vP4N+AskaQOpVeyr9xoo="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-5MTjLpIeAXRk7AsHWZh/31739CWe/oojwaERXBKReFY="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-VZMKnxxhbgQJLoi91d3nKRJi8T7cSIbOqIwEZ3uD+zY="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-Hvlz6R8hutasadu92lX/QXF/hhf24My3cuC+glWVtwk="; };
  };

  platform = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "coderabbit";
  inherit version;

  src = fetchurl {
    url = "https://cli.coderabbit.ai/releases/${version}/coderabbit-${platform.suffix}.zip";
    hash = platform.hash;
  };

  nativeBuildInputs = [ unzip ] ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapBuddy ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libsecret ];

  unpackPhase = ''
    unzip $src
  '';

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 coderabbit $out/bin/coderabbit
    ln -s $out/bin/coderabbit $out/bin/cr
    runHook postInstall
  '';

  meta = with lib; {
    description = "CodeRabbit CLI — AI-powered code review from the command line";
    homepage = "https://coderabbit.ai";
    changelog = "https://docs.coderabbit.ai/changelog";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames platformMap;
    mainProgram = "coderabbit";
  };
}
