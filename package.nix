{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.7.0";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-o3A45u+lzFkTr2rO1VClgtnJzbkbSgSG+dNQ7wT6qqw="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-Pj3vFdp/F9YB/5Dj0dge2TtJicaudQngWSbWBmmBWNQ="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-qgpH/wGqhJ1h7tJ0ZPTuI2Afat1QwBRQwWiaWAKXDHY="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-VTmRD9ZHRTUbRB0zCadn4WtJphkWzFl4PQm3SOKkgz4="; };
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
