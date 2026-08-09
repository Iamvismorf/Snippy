#include "Clipboard.hpp"

#include <QGuiApplication>

Clipboard::Clipboard(QObject *parent)
    : QObject(parent), m_clipboard(QGuiApplication::clipboard()) {}

void Clipboard::requestCopyImage(QQuickItem *item) {
  m_grabedImage = item->grabToImage();
  connect(m_grabedImage.data(), &QQuickItemGrabResult::ready, this,
          &Clipboard::copyImage, Qt::SingleShotConnection);
}

void Clipboard::copyImage() {
  if (m_grabedImage.data()) {
    m_clipboard->setImage(m_grabedImage->image());
    emit copied(true);
  } else {
    emit copied(false);
  }
}
