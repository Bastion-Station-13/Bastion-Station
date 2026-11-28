import {
  type MouseEvent,
  type ReactNode,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';
import { Button, Section } from 'tgui-core/components';

import {
  areaAtTile,
  clampPan,
  clampZoom,
  FOCUS_ZOOM,
  fitMap,
  type MapFocus,
  MIN_ZOOM,
  panToCenter,
  pointToTile,
  type StationMapData,
} from './stationMapUtils';

type Props = {
  map: StationMapData;
  /** Centers the map on a point and zooms in, give a new object to do it again */
  focus?: MapFocus;
  /** Gets the zoom, so what it draws can stay the same size */
  children?: (zoom: number) => ReactNode;
};

type Drag = {
  mouseX: number;
  mouseY: number;
  panX: number;
  panY: number;
};

export const StationMap = (props: Props) => {
  const { map, focus, children } = props;

  const viewRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<HTMLDivElement>(null);
  const dragRef = useRef<Drag | null>(null);

  const [view, setView] = useState({ width: 0, height: 0 });
  const [zoom, setZoom] = useState(MIN_ZOOM);
  const [rawPan, setRawPan] = useState({ x: 0, y: 0 });
  const [dragging, setDragging] = useState(false);
  const [hover, setHover] = useState<{
    area: string;
    x: number;
    y: number;
  } | null>(null);

  useLayoutEffect(() => {
    const element = viewRef.current;
    if (!element) {
      return;
    }
    const measure = () =>
      setView({ width: element.clientWidth, height: element.clientHeight });
    measure();
    if (typeof ResizeObserver === 'undefined') {
      return;
    }
    const observer = new ResizeObserver(measure);
    observer.observe(element);
    return () => observer.disconnect();
  }, []);

  const size = fitMap(map, view.width, view.height);
  const pan = clampPan(
    rawPan,
    zoom,
    size.width,
    size.height,
    view.width,
    view.height,
  );

  const sizeRef = useRef(size);
  sizeRef.current = size;

  useEffect(() => {
    if (!focus) {
      return;
    }
    setZoom(FOCUS_ZOOM);
    setRawPan(
      panToCenter(
        focus,
        FOCUS_ZOOM,
        sizeRef.current.width,
        sizeRef.current.height,
      ),
    );
  }, [focus]);

  const updateHover = (event: MouseEvent<HTMLDivElement>) => {
    const mapRect = mapRef.current?.getBoundingClientRect();
    const viewRect = viewRef.current?.getBoundingClientRect();
    if (!mapRect || !viewRect || !mapRect.width || !mapRect.height) {
      setHover(null);
      return;
    }
    const tile = pointToTile(
      map,
      (event.clientX - mapRect.left) / mapRect.width,
      (event.clientY - mapRect.top) / mapRect.height,
    );
    const area = tile && areaAtTile(map, tile.x, tile.y);
    setHover(
      area
        ? {
            area,
            x: event.clientX - viewRect.left + 12,
            y: event.clientY - viewRect.top + 12,
          }
        : null,
    );
  };

  const handleMouseDown = (event: MouseEvent<HTMLDivElement>) => {
    if (event.button !== 0) {
      return;
    }
    dragRef.current = {
      mouseX: event.clientX,
      mouseY: event.clientY,
      panX: pan.x,
      panY: pan.y,
    };
    setDragging(true);
    setHover(null);
  };

  const handleMouseMove = (event: MouseEvent<HTMLDivElement>) => {
    const drag = dragRef.current;
    if (!drag) {
      updateHover(event);
      return;
    }
    setRawPan({
      x: drag.panX + event.clientX - drag.mouseX,
      y: drag.panY + event.clientY - drag.mouseY,
    });
  };

  const stopDragging = () => {
    dragRef.current = null;
    setDragging(false);
  };

  const changeZoom = (next: number) => {
    const nextZoom = clampZoom(next);
    setZoom(nextZoom);
    setRawPan(
      clampPan(pan, nextZoom, size.width, size.height, view.width, view.height),
    );
  };

  const reset = () => {
    setZoom(MIN_ZOOM);
    setRawPan({ x: 0, y: 0 });
  };

  return (
    <Section
      fill
      title="Station Map"
      buttons={
        <>
          <Button
            icon="search-plus"
            tooltip="Zoom in"
            onClick={() => changeZoom(zoom + 0.4)}
          />
          <Button
            icon="search-minus"
            tooltip="Zoom out"
            onClick={() => changeZoom(zoom - 0.4)}
          />
          <Button icon="undo" onClick={reset}>
            Reset
          </Button>
        </>
      }
    >
      <div
        ref={viewRef}
        onWheel={(event) => changeZoom(zoom + (event.deltaY < 0 ? 0.3 : -0.3))}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={stopDragging}
        onMouseLeave={() => {
          stopDragging();
          setHover(null);
        }}
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
          overflow: 'hidden',
          background: '#050505',
          border: '1px solid #1f1f1f',
          borderRadius: '4px',
          cursor: dragging ? 'grabbing' : 'grab',
        }}
      >
        <div
          ref={mapRef}
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            width: `${size.width}px`,
            height: `${size.height}px`,
            marginLeft: `${-size.width / 2}px`,
            marginTop: `${-size.height / 2}px`,
            backgroundImage: `url(${map.image})`,
            backgroundSize: '100% 100%',
            backgroundRepeat: 'no-repeat',
            imageRendering: 'pixelated',
            transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`,
            transformOrigin: 'center center',
            transition: dragging ? 'none' : 'transform 0.15s ease-out',
          }}
        >
          {children?.(zoom)}
        </div>
        {!!hover && !dragging && (
          <div
            style={{
              position: 'absolute',
              left: `${hover.x}px`,
              top: `${hover.y}px`,
              padding: '3px 8px',
              borderRadius: '3px',
              border: '1px solid rgba(255, 255, 255, 0.4)',
              background: 'rgba(0, 0, 0, 0.9)',
              color: '#ffffff',
              fontSize: '11px',
              fontWeight: 'bold',
              whiteSpace: 'nowrap',
              pointerEvents: 'none',
              zIndex: 30,
            }}
          >
            {hover.area}
          </div>
        )}
      </div>
    </Section>
  );
};
