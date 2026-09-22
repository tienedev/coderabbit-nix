{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.8.0";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-5gqkCCZsPiNQquiQsjmrjRwSs/YH9EdeHC3dRSmvHXE="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-Vw/QVpI5Nx3mt8sQBMdgBSxQfR+7MYm2kpiNfzgE7m0="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-zOvGM1/X/gu+KtWVqlf2hIkFUf8DEUyMwkA5UtnHrFI="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-dIJxGVuFzCRWE/Kv+rrNQYnHIfODn7FNPvzsz/2zgvU="; };
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
