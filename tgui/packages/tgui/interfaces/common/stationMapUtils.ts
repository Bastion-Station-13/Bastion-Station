export type StationMapData = {
  image: string;
  z: number;
  min_x: number;
  min_y: number;
  width: number;
  height: number;
  area_names: string[];
  // one row per y from the bottom, pairs of (index + 1 in area_names or 0, tile count)
  area_rows: number[][];
};

export type MapFocus = {
  left: number;
  bottom: number;
};

export const MIN_ZOOM = 1;
export const MAX_ZOOM = 4;
export const FOCUS_ZOOM = 2.5;

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));

export const clampZoom = (zoom: number) => clamp(zoom, MIN_ZOOM, MAX_ZOOM);

/** Where the middle of a tile is on the map, in percent from the left and bottom */
export const tileToPercent = (map: StationMapData, x: number, y: number) => ({
  left: ((x - map.min_x + 0.5) / map.width) * 100,
  bottom: ((y - map.min_y + 0.5) / map.height) * 100,
});

/** The name of the area on a tile, if it has one */
export const areaAtTile = (
  map: StationMapData,
  x: number,
  y: number,
): string | undefined => {
  const row = map.area_rows[y - map.min_y];
  let left = x - map.min_x;
  if (!row || left < 0) {
    return undefined;
  }
  for (let i = 0; i + 1 < row.length; i += 2) {
    if (left < row[i + 1]) {
      return row[i] ? map.area_names[row[i] - 1] : undefined;
    }
    left -= row[i + 1];
  }
  return undefined;
};

/** The tile under a point, given as fractions of the map from its left and top */
export const pointToTile = (
  map: StationMapData,
  fromLeft: number,
  fromTop: number,
) => {
  if (fromLeft < 0 || fromLeft > 1 || fromTop < 0 || fromTop > 1) {
    return undefined;
  }
  return {
    x: map.min_x + clamp(Math.floor(fromLeft * map.width), 0, map.width - 1),
    y:
      map.min_y +
      clamp(Math.floor((1 - fromTop) * map.height), 0, map.height - 1),
  };
};

/** How far the map has to move, in pixels, to put a point in the middle of the view */
export const panToCenter = (
  focus: MapFocus,
  zoom: number,
  mapWidth: number,
  mapHeight: number,
) => ({
  x: zoom * (0.5 - focus.left / 100) * mapWidth,
  y: zoom * (focus.bottom / 100 - 0.5) * mapHeight,
});

/** Keeps the zoomed map covering the view, so it can't be dragged away */
export const clampPan = (
  pan: { x: number; y: number },
  zoom: number,
  mapWidth: number,
  mapHeight: number,
  viewWidth: number,
  viewHeight: number,
) => {
  const maxX = Math.max(0, (zoom * mapWidth - viewWidth) / 2);
  const maxY = Math.max(0, (zoom * mapHeight - viewHeight) / 2);
  return {
    x: clamp(pan.x, -maxX, maxX),
    y: clamp(pan.y, -maxY, maxY),
  };
};

/** The size the whole map is shown at inside a view, keeping its shape */
export const fitMap = (
  map: StationMapData,
  viewWidth: number,
  viewHeight: number,
) => {
  const scale = Math.min(viewWidth / map.width, viewHeight / map.height);
  return {
    width: map.width * scale,
    height: map.height * scale,
  };
};
