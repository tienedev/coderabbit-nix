{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.7.3";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-yUDFmoJ+IHkFBjy2aozkY5KM0tcLe719mYzXn8UigA4="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-eWLKIAnMlsnST0ElRerZ6VuZQrtmnDHRB3/bssUuWyQ="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-6VVUbUnKsGesUOh4EN7uMRw4kU8J16qlxIrJQdd2hCM="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-T/6msq3X93nwnv+nU/3t0Lb757u7WlLbslq9fp1i0a8="; };
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
