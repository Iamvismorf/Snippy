#include "SvgItem.hpp"
#include <QImage>
#include <QPainter>
#include <QQuickWindow>
#include <QSGImageNode>

Snippy::SvgItem::SvgItem(QQuickItem *parent) : QQuickItem(parent) {
  setFlag(ItemHasContents, true);
}

void Snippy::SvgItem::setSource(const QUrl &newSource) {
  if (newSource == m_source) {
    return;
  }
  m_source = newSource;
  m_renderer = QSharedPointer<QSvgRenderer>::create(m_source.path());
  m_dirty = true;
  emit sourceChanged();
  update();
}

void Snippy::SvgItem::geometryChange(const QRectF &newGeometry,
                                     const QRectF &oldGeometry) {
  QQuickItem::geometryChange(newGeometry, oldGeometry);
  if (newGeometry.size() != oldGeometry.size()) {
    m_dirty = true;
    update();
  }
}

QSGNode *Snippy::SvgItem::updatePaintNode(QSGNode *oldNode,
                                          UpdatePaintNodeData *) {
  if (!m_renderer || !m_renderer->isValid() || width() <= 0 || height() <= 0) {
    delete oldNode;
    return nullptr;
  }

  auto *node = static_cast<QSGImageNode *>(oldNode);

  if (!node) {
    node = window()->createImageNode();
    node->setOwnsTexture(true);
  }

  if (m_dirty) {
    // Key part: rasterize at devicePixelRatio, not at 1x logical size
    const qreal dpr = window()->devicePixelRatio();
    const QSize pixelSize(qCeil(width() * dpr), qCeil(height() * dpr));

    QImage image(pixelSize, QImage::Format_ARGB32_Premultiplied);
    image.setDevicePixelRatio(dpr);
    image.fill(Qt::transparent);

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setRenderHint(QPainter::SmoothPixmapTransform, true);
    // Render into the full pixel rect — QSvgRenderer scales the SVG's
    // internal viewBox to fit this rect, which is what you want.
    m_renderer->render(&painter, QRectF(QPointF(0, 0), pixelSize));
    painter.end();

    QSGTexture *texture = window()->createTextureFromImage(
        image, QQuickWindow::TextureCanUseAtlas);
    // Linear filtering is correct here because texture pixels
    // now match (or exceed) display pixels 1:1 at this DPR
    texture->setFiltering(QSGTexture::Linear);
    node->setTexture(texture); // node owns it, replaces + deletes old one
    node->setOwnsTexture(true);

    m_dirty = false;
  }

  node->setRect(QRectF(0, 0, width(), height()));

  return node;
}
