{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs.qt6Packages;
    [
      qtbase
      qtdeclarative
    ]
    ++ [
      pkgs.qt6.wrapQtAppsHook
      pkgs.clang-tools
      pkgs.tokei
      pkgs.makeWrapper
      pkgs.cmake
      pkgs.kdePackages.kirigami
      pkgs.kdePackages.qttools
      pkgs.ninja
    ];

  QT_LOGGING_RULES = "quickshell.dbus.properties=false;kf.kirigami.platform=false;qt.qml.binding.removal.info=true";

  # Qt 6 specific environment variables
  shellHook = ''
    export QML_IMPORT_PATH=$(pwd)/build/qml:${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}
    setQtEnvironment=$(mktemp)
    random=$(openssl rand -base64 20 | sed "s/[^a-zA-Z0-9]//g")
    makeShellWrapper "$(type -p sh)" "$setQtEnvironment" "''${qtWrapperArgs[@]}" --argv0 "$random"
    sed "/$random/d" -i "$setQtEnvironment"
    source "$setQtEnvironment"
  '';
}
