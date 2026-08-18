#include "Clipboard.hpp"

#include <QGuiApplication>

Snippy::Clipboard::Clipboard(QObject *parent)
    : QObject(parent), m_clipboard(QGuiApplication::clipboard()) {}

void Snippy::Clipboard::requestCopyImage(QQuickItem *item) {
  m_grabedImage = item->grabToImage();
  connect(m_grabedImage.data(), &QQuickItemGrabResult::ready, this,
          &Clipboard::copyImage, Qt::SingleShotConnection);
}

void Snippy::Clipboard::copyImage() {
  if (m_grabedImage.data()) {
    m_clipboard->setImage(m_grabedImage->image());
    emit copied(m_grabedImage.data());
  } else {
    emit copied(nullptr);
  }
}
