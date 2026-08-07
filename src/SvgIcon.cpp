#include "./SvgIcon.hpp"

#include <QPainter>
#include <QQuickWindow>
#include <QSGImageNode>

SvgIcon::SvgIcon(QQuickItem *parent)
    : QQuickItem(parent)

{
  setImplicitSize(32, 32);
  m_svgRenderer.setAspectRatioMode(Qt::KeepAspectRatio);
  setFlag(QQuickItem::ItemHasContents);

  connect(this, &SvgIcon::sourceChanged, this, [this]() {
    m_svgRenderer.load(m_source.path());
    polish();
  });

  connect(this, &SvgIcon::colorChanged, this, [this]() { polish(); });
}

QSGNode *SvgIcon::updatePaintNode(QSGNode *oldnode, UpdatePaintNodeData *) {
  QSGImageNode *node = static_cast<QSGImageNode *>(oldnode);
  if (!node) {
    node = window()->createImageNode();
  }
  QSGTexture *texture = window()->createTextureFromImage(
      m_cachedImage, QQuickWindow::TextureCanUseAtlas);
  node->setOwnsTexture(true);
  node->setTexture(texture);
  QPointF position(

      ((width() - m_cachedImage.width()) / 2.0f),
      ((height() - m_cachedImage.height()) / 2.0f)

  );

  node->setRect(QRectF(position, node->texture()->textureSize()));

  return node;
}

void SvgIcon::geometryChange(const QRectF &newGeometry,
                             const QRectF &oldGeometry) {
  QQuickItem::geometryChange(newGeometry, oldGeometry);

  if (newGeometry.size() == oldGeometry.size()) {
    return;
  }
  polish();
}

void SvgIcon::componentComplete() {
  QQuickItem::componentComplete();
  polish();
}

void SvgIcon::rerender() {
  if (!m_svgRenderer.isValid() || !isComponentComplete()) {
    return;
  }

  qreal roundedWidth = std::min(width(), height());
  roundedWidth =
      std::round(roundedWidth * m_devicePixelRatio) / m_devicePixelRatio;

  m_cachedImage = QImage(roundedWidth, roundedWidth, QImage::Format_ARGB32);
  m_cachedImage.setDevicePixelRatio(m_devicePixelRatio);
  m_cachedImage.fill(Qt::transparent);

  QPainter svgpainter(&m_cachedImage);
  svgpainter.setRenderHints(QPainter::RenderHint::Antialiasing |
                            QPainter::RenderHint::SmoothPixmapTransform);
  m_svgRenderer.render(&svgpainter);
  svgpainter.end();

  QPainter colorPainter(&m_cachedImage);
  colorPainter.setCompositionMode(QPainter::CompositionMode_SourceIn);
  colorPainter.setRenderHints(QPainter::RenderHint::Antialiasing |
                              QPainter::RenderHint::SmoothPixmapTransform);
  colorPainter.fillRect(m_cachedImage.rect(), m_color);

  update();
}

void SvgIcon::updatePolish() { rerender(); }

void SvgIcon::itemChange(QQuickItem::ItemChange change,
                         const QQuickItem::ItemChangeData &value) {
  if (change == QQuickItem::ItemDevicePixelRatioHasChanged) {
    if (window()) {
      m_devicePixelRatio = window()->effectiveDevicePixelRatio();
    }
    polish();
  } else if (change == QQuickItem::ItemSceneChange) {
    if (value.window) {
      m_devicePixelRatio = value.window->effectiveDevicePixelRatio();
    }
    polish();
  }
  QQuickItem::itemChange(change, value);
}
