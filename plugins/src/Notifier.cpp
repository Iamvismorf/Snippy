// todo: summary
#include "Notifier.hpp"
#include <QDBusArgument>
#include <QDBusInterface>

Snippy::Notifier::Notifier(QObject *parent) : QObject(parent) {};

void Snippy::Notifier::notify(const QString &summary,
                              const QQuickItemGrabResult *grabedImage) {
  QDBusInterface notifInterface("org.freedesktop.Notifications",
                                "/org/freedesktop/Notifications",
                                "org.freedesktop.Notifications");
  QVariantHash hints;
  if (grabedImage && !grabedImage->image().isNull()) {

    QDBusArgument imageData;

    imageData.beginStructure();
    QImage img = grabedImage->image();
    bool hasAlphaChannel = img.hasAlphaChannel();
    imageData << img.width() << img.height() << img.bytesPerLine()
              << hasAlphaChannel << 8 << hasAlphaChannel + 3
              << QByteArray(reinterpret_cast<const char *>(img.constBits()),
                            img.sizeInBytes());
    imageData.endStructure();

    hints["image-data"] = QVariant::fromValue(imageData);

    notifInterface.call("Notify",

                        "Snippy", (uint32_t)0, "", summary,
                        "The screenshot was copied to clipboard", QStringList(),
                        hints, (int32_t)-1);
  } else {
    notifInterface.call("Notify",

                        "Snippy", (uint32_t)0, "", summary,
                        "Failed to copy the screenshot to clipboard",
                        QStringList(), hints, (int32_t)-1);
  }
}

void Snippy::Notifier::notify(bool status, const QString &summary,
                              const QUrl &url) {
  QDBusInterface notifInterface("org.freedesktop.Notifications",
                                "/org/freedesktop/Notifications",
                                "org.freedesktop.Notifications");
  QVariantHash hints;
  if (status) {
    hints["image-path"] = url.path();
    notifInterface.call("Notify",

                        "Snippy", (uint32_t)0, "", summary,
                        QString("The screenshot was saved as '%1' to '%2'")
                            .arg(url.fileName(), url.path()),
                        QStringList(), hints, (int32_t)-1);

  } else {
    notifInterface.call("Notify",

                        "Snippy", (uint32_t)0, "", summary,
                        "Failed to save the screenshot", QStringList(), hints,
                        (int32_t)-1);
  }
}
