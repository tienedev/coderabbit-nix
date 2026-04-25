{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.4.3";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-rFBa5eScw1/0n2of01NKNUKR09HlBwQqx10ksf9WPxo="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-RuZSxudEQeoY44y6V6fQr0NTNdEKhH7VJT2BmBrDHvo="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-j+NIGdqG41KV0MhUiPsJm2p3+53+9qqQn1f5tDXEW4c="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-B7yCofFT/1q0yBR0A0sIN78zEo3D1nbxGnpIRF3bArQ="; };
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
