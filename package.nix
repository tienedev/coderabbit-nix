{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.9.2";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-spvvVf1aQaKHKThRas3kb0wMz4/YHA2GgpxDWnWl/Zo="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-RWfqQtDFKm9RNBgNIuXw3k51cys+JfsaXFpDPMqhDZw="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-4vJdg51KvQTQfNvRsXHYZI3QhdUp98s3MwiidTp7Y5k="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-vzypbAjlpXhug3A+KF4w20PdJuDm3Fm4LZB03cqluFQ="; };
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
