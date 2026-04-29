{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.4.4";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-BBZbcglgXN6pMhHXlJw+RKraizCS+2zoBPm5aVqzgnM="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-5yyAYemBkFaU+n1IYDyKPcC31nB/AUCIneavsRm08gw="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-4y+JnIM5c8R1IYw2iNAtQ91OGEd8I7Xqe5Wwz0FAJ+U="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-+8Uf+GXdcbTwhRGUn3wOOiOs0t1u7GwC6bgayjgmYm8="; };
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
