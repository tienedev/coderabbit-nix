{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.4.0";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-EG6roPruJ62ztp9dS0b9BfLeP5Ukgdx5yB9pt+MlV44="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-ntQR9blq53SMWsyWPDeEATlBfIfJ06JHv550Hb+oq/8="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-ZNViHoHzcrzwADiPdUiQX6s6n1iD/lSHVerMLK8kxpY="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-yxUPOuXVcP9AMARlum+AQG4fZdqG7p/Vw90QEbmJ0Zo="; };
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
