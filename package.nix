{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.6.3";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-hO5wwj600iZmtewu5Do0fhAbr09l+Y9mZmPef4s0twk="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-vFgU6at+BQhfGmiW1bcRTqQsH6cyGKBzXSmlUk5o/ZE="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-ZuZD7xDgyingPUvH52UH5niBCkXAQSMS+cei0hoREF0="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-EjR5cVeV5tQA8uW5sBh60werMwidHhpltNYyUyFbCIk="; };
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
