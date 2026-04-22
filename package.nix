{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.4.2";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-UICH1BOgiR4cOpNgmmW3Orp5wu3t62039hCuSl7O4/o="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-m3fnx8xKbKaYD8OI8I4HNNHCPgPeZbyKkC3nvq83CdY="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-Ig2MUIr5NXorGOFZwqqJMN5qrOeD96Cy8uD7tUapFz8="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-oaFC1W48ps/ojUlV8gdHE4hdN5NgvyLpg2AksgMkQIc="; };
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
