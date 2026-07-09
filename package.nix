{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wrapBuddy ? null,
  libsecret,
}:

let
  version = "0.6.5";

  platformMap = {
    x86_64-linux = { suffix = "linux-x64"; hash = "sha256-goDc+CKNCHt4++iVW4xe8/g/c/1G2aAJRTlIVH0wSpk="; };
    aarch64-linux = { suffix = "linux-arm64"; hash = "sha256-8FYSDvih62Qc+5tAu9NtrSg180Gh3KCep3Z6lMHoMJs="; };
    x86_64-darwin = { suffix = "darwin-x64"; hash = "sha256-/y3hqI/tcrS+qYyAaoHGfpq/0dDMYkRdw19KlF9uVuo="; };
    aarch64-darwin = { suffix = "darwin-arm64"; hash = "sha256-V1MNVXym919ItsJkoQ2BabUjNL6ZHEhb4kApVL22zsw="; };
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
