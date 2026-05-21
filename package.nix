{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.5.1";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-+iuoLgYemQDvoyU9wSMk2tX8MeMAlgndKx7Gk/0nBnI="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-RioZvIf3mtbwb58K8YB21Cb3yjmkXbBwUjA76fHHsa4="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-fRodzcsf/Aiig1vl8GCy8M2ITmhzBkkmUMCp4IScwFw="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-y3HFloerlzO9hYl6csiV74culKGmz8DP340klFUo+6I="; };
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
