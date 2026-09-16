{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.7.8";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-UqtggVSZEbCxYiO+QW4epdlsqKYG0rXD5vGURDk8SyA="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-ROTYRUlf1T/7w4Y4F6uvXAdwJ+rYmWDtqE7KODoZp4Y="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-1kB3RiA0MutpQFosFgY3LnT01RwPF1JnYR/H2xlrfI8="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-odZ43T7TZkem3ILZFCZytKXomUNvl0RO1/2V3JhovZo="; };
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
