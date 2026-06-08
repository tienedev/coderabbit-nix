{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.5.4";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-k3GiuHaISPaLGj8X5jFUkQCfRhCIIK3gl9qY/sW6xwo="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-5X5TzUR+G4+u12fDRxW/qygW30u15+LrkbYWOvixXcg="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-Q8NtILwwaGnidCH8f0UyvQ291O2fo1fYXjVF2lu45SI="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-FDmD+hzibKSf8EE+kv0uaP/ey/3coemKGlWxchDhhaA="; };
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
