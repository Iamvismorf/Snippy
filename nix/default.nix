{
  stdenv,
  lib,
  qt6,
  cmake,
  makeWrapper,
  kdePackages,
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

  qml-plugin = stdenv.mkDerivation {
    name = "snippy-qml-plugin";
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
    name = "snippy";
    inherit src;

    nativeBuildInputs = [makeWrapper qt6.wrapQtAppsHook];
    buildInputs = [qml-plugin kdePackages.kirigami qt6.qtbase];

    installPhase = ''
      mkdir -p $out/share/snippy
      cp -r . $out/share/snippy

      makeWrapper ${quickshell}/bin/qs $out/bin/snippy \
         --set FONTCONFIG_FILE "${defaultFont}" \
         --add-flags "-p $out/share/snippy"
    '';

    passthru = {
      inherit qml-plugin;
    };
  }
