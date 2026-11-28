import { afterEach, describe, expect, it, mock } from 'bun:test';
import { act, type ReactNode } from 'react';
import { createRoot, type Root } from 'react-dom/client';

import {
  gameDataAtom,
  gameStaticDataAtom,
  resetStore,
  store,
} from './events/store';

const actCalls: [string, Record<string, unknown>][] = [];

mock.module('./events/act', () => ({
  sendAct: (action: string, payload: Record<string, unknown>) => {
    actCalls.push([action, payload]);
  },
}));

mock.module('./layouts', () => {
  const Window = (props: { children?: ReactNode }) => (
    <div>{props.children}</div>
  );
  Window.Content = (props: { children?: ReactNode }) => (
    <div>{props.children}</div>
  );
  return { Window };
});

(
  globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }
).IS_REACT_ACT_ENVIRONMENT = true;

const { CrewConsoleNova } = await import('./interfaces/CrewConsoleNova');

// 100 by 80 tiles with the bottom left tile at 50, 60, on z level 2
const map = {
  image: 'data:image/png;base64,AAAA',
  z: 2,
  min_x: 50,
  min_y: 60,
  width: 100,
  height: 80,
  area_names: ['Bridge', 'Medbay'],
  area_rows: Array.from({ length: 80 }, () => [1, 50, 2, 50]),
};

const sensor = (ref: string, name: string, extra = {}) => ({
  ref,
  name,
  assignment: 'Captain',
  ijob: 0,
  life_status: 0,
  oxydam: 0,
  toxdam: 0,
  burndam: 0,
  brutedam: 0,
  health: 100,
  area: 'Bridge',
  ...extra,
});

const sensors = [
  // the bottom left tile
  sensor('[0x1]', 'Alice', { job_icon: 'job_icons8x8 captain', x: 50, y: 60 }),
  // the top right tile, with no job icon
  sensor('[0x2]', 'Bob', { ijob: 41, x: 149, y: 139 }),
  // no position, because the sensors only give the area
  sensor('[0x3]', 'Carol', {
    ijob: 23,
    job_icon: 'job_icons8x8 medical_doctor',
  }),
];

let root: Root | undefined;
let container: HTMLDivElement | undefined;

const render = (data: Record<string, unknown>, staticData = {}) => {
  store.set(gameDataAtom, { sensors, link_allowed: 0, z: 2, ...data });
  store.set(gameStaticDataAtom, staticData);
  container = document.createElement('div');
  document.body.appendChild(container);
  root = createRoot(container);
  act(() => root?.render(<CrewConsoleNova />));
  return container;
};

afterEach(() => {
  act(() => root?.unmount());
  container?.remove();
  root = undefined;
  container = undefined;
  actCalls.length = 0;
  resetStore();
});

const blips = (where: HTMLElement) =>
  Array.from(where.querySelectorAll<HTMLElement>('div')).filter(
    (element) => element.style.bottom !== '',
  );

const buttons = (where: HTMLElement) =>
  Array.from(where.querySelectorAll<HTMLElement>('.Button'));

const buttonWith = (where: HTMLElement, text: string) =>
  buttons(where).find(
    (button) => button.textContent?.trim() === text,
  ) as HTMLElement;

const hasMap = (where: HTMLElement) =>
  (where.textContent ?? '').includes('Station Map');

const hover = (element: Element) =>
  act(() => {
    element.dispatchEvent(new MouseEvent('mouseover', { bubbles: true }));
  });

const click = (element: Element) =>
  act(() => {
    element.dispatchEvent(new MouseEvent('click', { bubbles: true }));
  });

describe('crew console without a map', () => {
  it('is only the table, as before', () => {
    const page = render({}, { map: null });
    expect(hasMap(page)).toBe(false);
    expect(blips(page)).toHaveLength(0);
    expect(page.textContent).toContain('Alice');
    expect(page.textContent).toContain('Bob');
    // nobody can be tracked from here
    expect(page.textContent).not.toContain('Tracking');
    expect(buttonWith(page, 'Track')).toBeUndefined();
  });

  it('still lets an AI track', () => {
    const page = render({ link_allowed: 1 }, { map: null });
    expect(page.textContent).toContain('Tracking');
    click(buttonWith(page, 'Track'));
    expect(actCalls).toEqual([['select_person', { ref: '[0x1]' }]]);
  });
});

describe('crew console with a map', () => {
  it('draws the people who have a position where their tile is', () => {
    const page = render({}, { map });
    expect(hasMap(page)).toBe(true);
    const drawn = blips(page);
    expect(drawn).toHaveLength(2);

    // the middle of the bottom left tile and of the top right tile
    expect(drawn[0].style.left).toBe('0.5%');
    expect(drawn[0].style.bottom).toBe('0.625%');
    expect(drawn[1].style.left).toBe('99.5%');
    expect(drawn[1].style.bottom).toBe('99.375%');
  });

  it('shows the job icon sprite, and a dot for someone without one', () => {
    const page = render({}, { map });
    const [alice, bob] = blips(page);
    expect(alice.querySelector('.job_icons8x8.captain')).not.toBeNull();
    expect(bob.querySelector('[class*="job_icons"]')).toBeNull();
    // the table has the icons too
    expect(
      page.querySelectorAll(
        '.job_icons8x8.captain, .job_icons8x8.medical_doctor',
      ),
    ).toHaveLength(3);
  });

  it('draws nobody when the map is of another level', () => {
    const page = render({ z: 3 }, { map });
    expect(hasMap(page)).toBe(true);
    expect(blips(page)).toHaveLength(0);
  });

  it('lights up the blip of a row, and the other way around', () => {
    const page = render({}, { map });
    const [alice, bob] = blips(page);
    expect(alice.style.zIndex).toBe('2');

    const row = Array.from(page.querySelectorAll('.candystripe')).find(
      (entry) => entry.textContent?.includes('Alice'),
    ) as HTMLElement;
    hover(row);
    expect(blips(page)[0].style.zIndex).toBe('20');
    expect(blips(page)[1].style.zIndex).toBe('2');

    hover(bob);
    expect(blips(page)[1].style.zIndex).toBe('20');
    expect(
      Array.from(page.querySelectorAll<HTMLElement>('.candystripe')).find(
        (entry) => entry.textContent?.includes('Bob'),
      )?.style.backgroundColor,
    ).not.toBe('');
  });

  it('focuses the map on someone with Track, only if they have a position', () => {
    const page = render({}, { map });
    expect(blips(page)[0].style.transform).toContain('scale(1)');

    const tracks = buttons(page).filter(
      (button) => button.textContent?.trim() === 'Track',
    );
    expect(tracks).toHaveLength(3);
    // Carol has no position
    expect(tracks[2].className).toContain('disabled');
    expect(tracks[0].className).not.toContain('disabled');

    click(tracks[0]);
    // zoomed in, so the icons are scaled back down to stay the same size
    expect(blips(page)[0].style.transform).toContain('scale(0.4)');
    expect(actCalls).toHaveLength(0);
  });

  it('tracks for an AI instead of moving the map', () => {
    const page = render({ link_allowed: 1 }, { map });
    click(blips(page)[1]);
    expect(actCalls).toEqual([['select_person', { ref: '[0x2]' }]]);
    expect(blips(page)[1].style.transform).toContain('scale(1)');
  });

  it('hides and shows the map', () => {
    const page = render({}, { map });
    const toggle = buttons(page).find((button) =>
      button.querySelector('[class*="chevron-right"]'),
    ) as HTMLElement;
    expect(toggle).toBeDefined();

    click(toggle);
    expect(hasMap(page)).toBe(false);
    expect(blips(page)).toHaveLength(0);
    // the table is still there and the button to get the map back
    expect(page.textContent).toContain('Alice');
    const back = buttons(page).find((button) =>
      button.querySelector('[class*="chevron-left"]'),
    ) as HTMLElement;
    expect(back).toBeDefined();

    click(back);
    expect(hasMap(page)).toBe(true);
    expect(blips(page)).toHaveLength(2);
  });
});
