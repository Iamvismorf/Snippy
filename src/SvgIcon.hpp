#pragma once

#include <QPixmap>
#include <QQuickPaintedItem>
#include <QSvgRenderer>

class SvgIcon : public QQuickItem {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
  Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

public:
  SvgIcon(QQuickItem *parent = nullptr);

  const QUrl &source() const { return m_source; }
  void setSource(const QUrl &newSource) {
    if (newSource == m_source) {
      return;
    }
    m_source = newSource;
    emit sourceChanged();
  }

  const QColor &color() const { return m_color; }
  void setColor(const QColor &newColor) {
    if (newColor == m_color) {
      return;
    }
    m_color = newColor;
    emit colorChanged();
  }

  void componentComplete() override;

signals:
  void sourceChanged();
  void colorChanged();

private:
  void geometryChange(const QRectF &newGeometry,
                      const QRectF &oldGeometry) override;

  QSvgRenderer m_svgRenderer;
  void itemChange(QQuickItem::ItemChange change,
                  const QQuickItem::ItemChangeData &value) override;
  QSGNode *updatePaintNode(QSGNode *node, UpdatePaintNodeData *) override;

  void updatePolish() override;
  QUrl m_source;
  QColor m_color;
  QImage m_cachedImage;
  qreal m_devicePixelRatio = 1.0;

  void rerender();
};
