{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.5.2";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-ybnZQkU+pGsXnQX/wPrrcXZ+8mSqiIAHgBA1AlIj4so="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-jF0TdtkvLRvv3b3utDHo2Qn6Stg20JgV/knPFCvIqa4="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-OtTRg8FXBZI2sc5nVr2a4OHmr6S+Gh/sTPqgXdnd3Yc="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-xxQ/Ai5G8OvQAHAQdi0h3RUvR7u1mEc1hogeIHM6MDA="; };
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
