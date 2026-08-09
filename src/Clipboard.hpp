#pragma once

#include <QClipboard>
#include <QObject>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QtQmlIntegration>

class Clipboard : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit Clipboard(QObject *parent = nullptr);
  Q_INVOKABLE void requestCopyImage(QQuickItem *item);

signals:
  void copied(bool status);

private:
  QClipboard *m_clipboard;
  QSharedPointer<QQuickItemGrabResult> m_grabedImage;

private slots:
  void copyImage();
};
