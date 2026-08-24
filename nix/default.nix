{
  self,
  stdenv,
  lib,
  qt6,
  cmake,
  makeWrapper,
  kirigami,
  ninja,
  quickshell,
  makeFontsConf,
  atkinson-hyperlegible-next,
}: let
  src = let
    root = ./..;
  in
    lib.fileset.toSource {
      inherit root;
      fileset =
        lib.fileset.unions
        (
          lib.map (x: root + "/${x}")
          ["annotation" "assets" "components" "core" "lib" "singletons" "toolbar" "shell.qml"]
        );
    };

  defaultFont = makeFontsConf {
    fontDirectories = [atkinson-hyperlegible-next];
  };
  version = self.shortRev or self.dirtyShortRev or "UNKNOWN";

  qml-plugin = stdenv.mkDerivation {
    pname = "snippy-qml-plugin";
    inherit version;
    src = ../plugins;

    nativeBuildInputs = [
      cmake
      ninja
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qtdeclarative
    ];

    dontWrapQtApps = true;
    cmakeFlags = [
      (lib.cmakeFeature "INSTALL_QMLDIR" qt6.qtbase.qtQmlPrefix)
    ];
  };
in
  stdenv.mkDerivation {
    pname = "snippy";
    inherit version;
    inherit src;

    nativeBuildInputs = [makeWrapper qt6.wrapQtAppsHook];
    buildInputs = [qml-plugin kirigami qt6.qtbase];

    installPhase = ''
      mkdir -p $out/share/snippy
      cp -r . $out/share/snippy

      makeWrapper ${quickshell}/bin/qs $out/bin/snippy \
         --set FONTCONFIG_FILE "${defaultFont}" \
         --add-flags "-n" \
         --add-flags "-p $out/share/snippy"
    '';

    passthru = {
      inherit qml-plugin;
    };
  }
