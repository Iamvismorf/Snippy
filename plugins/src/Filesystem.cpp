#include "Filesystem.hpp"
#include <QDir>
#include <QStandardPaths>

Snippy::Filesystem::Filesystem(QObject *parent) : QObject(parent) {};

QString Snippy::Filesystem::getHomeDir() { return QDir::homePath(); }

QString Snippy::Filesystem::getConfigDir() {
  return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) +
         "/snippy";
}
QString Snippy::Filesystem::getConfigFile() {
  return this->getConfigDir() + "/config.json";
}

void Snippy::Filesystem::createSaveDir(const QString &dirpath) {
  if (!QDir::temp().mkpath(this->getHomeDir() + "/" + dirpath)) {
    qDebug() << "Something went wrong while trying to create save directory";
    return;
  }
}
