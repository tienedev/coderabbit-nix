{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.9.3";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-2IaQGlv/2dc1m80Q6S4n+h5V6Kf42isd/NQlp/ie3Es="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-QxOzklPvw7W9BygZLYDIFSUfnm+fFXvLa/cBzyXS6Ks="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-jJ6lww4Pjc/kBe1VDx5vKXD5Xm4aE3StCT0BeS9xCQ8="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-mDbOSwPq/NBy6U7lPQj8O2wHGc3q3lRXGEJNYr4gwVg="; };
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
