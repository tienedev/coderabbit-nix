{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.3.11";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-J69gcDX65YTYdmPidDgXlEGDRl17zIp6dTr/LNl0FCg="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-V77KLrBR4OXuO8VmoF07xrrttRbC2NdpQHivf7E+o6k="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-5jkX5/UJ7yWmUUuGFzrkpi8wGR3prNmvedyw9lCrpEU="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-HCPtqC5Cg6ZONbmCY3KVGkhr2LgZc9Mn9zEOtroRLAE="; };
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
