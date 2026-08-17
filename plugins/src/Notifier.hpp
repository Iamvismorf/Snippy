#pragma once

#include <QObject>
#include <QQuickItemGrabResult>
#include <QtQmlIntegration/qqmlintegration.h>
class Notifier : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit Notifier(QObject *parent = nullptr);
  Q_INVOKABLE void notify(const QString &summary,
                          const QQuickItemGrabResult *grabedImage);
  Q_INVOKABLE void notify(bool status, const QString &summary, const QUrl &url);
};
