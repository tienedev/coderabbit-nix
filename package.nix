{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.9.0";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-VuTJnenREQbD5r8xA0hk2490bLl8nq+UcK3PpkYdpm8="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-rY9wB0KYG+uHWRYNu9eGGDrz12yX0VlePWQJnk8TySQ="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-ZP3IRmspAPmP3y31FaXzvLrg9E1DDPtr7IF2ovBwh7s="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-9fIPtzGKyZtv/fMGq+PIK4DtI4IRblAWNgWlabWVg98="; };
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
