#include "Notifier.hpp"
#include <QDBusArgument>
#include <QDBusInterface>

Notifier::Notifier(QObject *parent) : QObject(parent) {};

void Notifier::notify(const QString &summary,
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

    // clang-format off
    notifInterface.call(
        "Notify",

        "Snippy", 
        (uint32_t)0, 
        "", 
        summary,
        "The screenshot was opied to clipboard",
        QStringList(),
        hints,
        (int32_t)-1
    );
    } // clang-format on
  else {
    // clang-format off
    notifInterface.call(
        "Notify",

        "Snippy", 
        (uint32_t)0, 
        "", 
        summary,
        "Failed to copy the screenshot to clipboard",
        QStringList(),
        hints,
        (int32_t)-1
    );
    // clang-format on
  }
}
