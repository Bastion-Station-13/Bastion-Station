import { describe, expect, it } from 'bun:test';

import {
  areaAtTile,
  clampPan,
  clampZoom,
  fitMap,
  MAX_ZOOM,
  MIN_ZOOM,
  panToCenter,
  pointToTile,
  type StationMapData,
  tileToPercent,
} from './interfaces/common/stationMapUtils';

// 100 by 50 tiles with the bottom left tile at 10, 20
const map: StationMapData = {
  image: '',
  z: 2,
  min_x: 10,
  min_y: 20,
  width: 100,
  height: 50,
  area_names: ['Bridge', 'Medbay'],
  area_rows: Array.from({ length: 50 }, (_, row) =>
    // bottom row is all Bridge, the rest has 30 tiles of nothing, 20 Bridge and 50 Medbay
    row === 0 ? [1, 100] : [0, 30, 1, 20, 2, 50],
  ),
};

describe('tileToPercent', () => {
  it('puts the corner tiles in the middle of their tile', () => {
    expect(tileToPercent(map, 10, 20)).toEqual({ left: 0.5, bottom: 1 });
    const far = tileToPercent(map, 109, 69);
    expect(far.left).toBeCloseTo(99.5);
    expect(far.bottom).toBeCloseTo(99);
  });
});

describe('areaAtTile', () => {
  it('reads the run length rows', () => {
    expect(areaAtTile(map, 10, 20)).toBe('Bridge');
    expect(areaAtTile(map, 109, 20)).toBe('Bridge');
    expect(areaAtTile(map, 10, 21)).toBeUndefined();
    expect(areaAtTile(map, 39, 21)).toBeUndefined();
    expect(areaAtTile(map, 40, 21)).toBe('Bridge');
    expect(areaAtTile(map, 59, 21)).toBe('Bridge');
    expect(areaAtTile(map, 60, 21)).toBe('Medbay');
    expect(areaAtTile(map, 109, 21)).toBe('Medbay');
  });

  it('has nothing outside of the map', () => {
    expect(areaAtTile(map, 9, 20)).toBeUndefined();
    expect(areaAtTile(map, 110, 20)).toBeUndefined();
    expect(areaAtTile(map, 10, 19)).toBeUndefined();
    expect(areaAtTile(map, 10, 70)).toBeUndefined();
  });
});

describe('pointToTile', () => {
  it('finds the tile under the corners, with the top of the map being the highest y', () => {
    expect(pointToTile(map, 0, 0)).toEqual({ x: 10, y: 69 });
    expect(pointToTile(map, 1, 1)).toEqual({ x: 109, y: 20 });
    expect(pointToTile(map, 0, 1)).toEqual({ x: 10, y: 20 });
    expect(pointToTile(map, 1, 0)).toEqual({ x: 109, y: 69 });
  });

  it('is outside of the map', () => {
    expect(pointToTile(map, -0.01, 0.5)).toBeUndefined();
    expect(pointToTile(map, 0.5, 1.01)).toBeUndefined();
  });

  it('gives back the tile that tileToPercent placed', () => {
    for (const [x, y] of [
      [10, 20],
      [57, 33],
      [109, 69],
      [10, 69],
      [109, 20],
    ]) {
      const { left, bottom } = tileToPercent(map, x, y);
      expect(pointToTile(map, left / 100, 1 - bottom / 100)).toEqual({ x, y });
    }
  });
});

describe('panToCenter', () => {
  it('does not move for the middle of the map', () => {
    const pan = panToCenter({ left: 50, bottom: 50 }, 2.5, 400, 200);
    expect(pan.x).toBeCloseTo(0);
    expect(pan.y).toBeCloseTo(0);
  });

  it('moves the map the other way from where the point is', () => {
    // a point on the left edge needs the map pushed right, one at the top pushed down
    const left = panToCenter({ left: 0, bottom: 50 }, 2, 400, 200);
    expect(left.x).toBeCloseTo(400);
    const top = panToCenter({ left: 50, bottom: 100 }, 2, 400, 200);
    expect(top.y).toBeCloseTo(200);
  });
});

describe('clampPan', () => {
  it('does not move a map that fits the view', () => {
    const pan = clampPan({ x: 50, y: -50 }, 1, 400, 200, 400, 300);
    expect(pan.x).toBeCloseTo(0);
    expect(pan.y).toBeCloseTo(0);
  });

  it('keeps a zoomed map over the view', () => {
    // 2x of 400 is 800, in a view of 400 that leaves 200 to each side
    expect(clampPan({ x: 500, y: 0 }, 2, 400, 200, 400, 400).x).toBe(200);
    expect(clampPan({ x: -500, y: 0 }, 2, 400, 200, 400, 400).x).toBe(-200);
    expect(clampPan({ x: 120, y: 0 }, 2, 400, 200, 400, 400).x).toBe(120);
  });
});

describe('fitMap and zoom', () => {
  it('keeps the shape of the map', () => {
    expect(fitMap(map, 500, 500)).toEqual({ width: 500, height: 250 });
    expect(fitMap(map, 1000, 100)).toEqual({ width: 200, height: 100 });
    expect(fitMap(map, 0, 0)).toEqual({ width: 0, height: 0 });
  });

  it('limits the zoom', () => {
    expect(clampZoom(0.2)).toBe(MIN_ZOOM);
    expect(clampZoom(9)).toBe(MAX_ZOOM);
    expect(clampZoom(2)).toBe(2);
  });
});
