#include "./SvgIcon.hpp"

#include <QPainter>
#include <QQuickWindow>

SvgIcon::SvgIcon(QQuickItem *parent)
    : QQuickPaintedItem(parent)

{
  setImplicitSize(32, 32);
  m_svgRenderer.setAspectRatioMode(Qt::KeepAspectRatio);
  setSmooth(false);

  connect(this, &SvgIcon::sourceChanged, this, [this]() {
    m_svgRenderer.load(m_source.path());
    polish();
  });

  connect(this, &SvgIcon::colorChanged, this, [this]() { polish(); });
}

void SvgIcon::paint(QPainter *painter) {
  if (m_cachedPixmap.isNull()) {
    return;
  }
  painter->drawPixmap(QPointF(width() / 2.0f - m_cachedPixmap.width() / 2.0f,
                              height() / 2.0f - m_cachedPixmap.height() / 2.0f),
                      m_cachedPixmap);
}

void SvgIcon::geometryChange(const QRectF &newGeometry,
                             const QRectF &oldGeometry) {
  QQuickPaintedItem::geometryChange(newGeometry, oldGeometry);

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

  qreal side = qMin(width(), height()) * m_devicePixelRatio;

  m_cachedPixmap = QPixmap(side, side);
  m_cachedPixmap.setDevicePixelRatio(m_devicePixelRatio);
  m_cachedPixmap.fill(Qt::transparent);

  QPainter svgpainter(&m_cachedPixmap);
  m_svgRenderer.render(&svgpainter);
  svgpainter.end();

  QPainter colorPainter(&m_cachedPixmap);
  colorPainter.setCompositionMode(QPainter::CompositionMode_SourceIn);
  colorPainter.fillRect(m_cachedPixmap.rect(), m_color);

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
