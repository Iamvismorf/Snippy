#pragma once
#include <QFile>
#include <QJSValue>
#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

namespace Snippy {
class Filesystem : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
public:
  Filesystem(QObject *parent = nullptr);

  Q_INVOKABLE QString getConfigFile();
  Q_INVOKABLE void createSaveDir(const QString &dirpath);

signals:
  void configFileCreated();

private:
  QString getConfigDir();
  QString getHomeDir();
};
} // namespace Snippy
