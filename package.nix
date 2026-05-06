{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.4.5";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-2burC25B/3CFlt5HwmBt84IMz2xltbFfDkeO8HawW6A="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-lTRZ4X36qOAIcpLAdOS81QUnJmcUsS4OBOsK+gPA+0M="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-WG26o4Swlwqs+si5okIDjNqCBu3QLaEGQnEvyqsqv6M="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-giH+k/IT17ll05iY6lvhnJleO2yoeVCa67SOUxjEEg0="; };
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
