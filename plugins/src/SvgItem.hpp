// svgitem.h
#pragma once
#include <QQuickItem>
#include <QSharedPointer>
#include <QSvgRenderer>

namespace Snippy {
class SvgItem : public QQuickItem {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
  Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

public:
  explicit SvgItem(QQuickItem *parent = nullptr);

  const QUrl &source() const { return m_source; }
  void setSource(const QUrl &newSource);

  const QColor &color() const { return m_color; }
  void setColor(const QColor &newColor) {
    if (newColor == m_color) {
      return;
    }
    m_color = newColor;
    emit colorChanged();
  }

signals:
  void sourceChanged();
  void colorChanged();

protected:
  QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;
  void geometryChange(const QRectF &newGeometry,
                      const QRectF &oldGeometry) override;

private:
  QUrl m_source;
  QColor m_color;

  QSharedPointer<QSvgRenderer> m_renderer;
  bool m_dirty = true; // needs re-render (source or size changed)
};
} // namespace Snippy
