{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.4.1";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-j+vmIsC22gqBtU6DXbpuUwdI6lqF6l+ThGPypiOBADw="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-S38iYcVVLMWj/lz0ontmroF/UXrOnjmCY9zb2Ti8DSE="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-45dd3dMlTH5d6tDKkqqtz8of15tPvpf+9BQ7rwLfYv8="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-8tHaZnurBb8HqxRjj4uPLLvy0rl4oTyoVqvbDN3TPGI="; };
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
