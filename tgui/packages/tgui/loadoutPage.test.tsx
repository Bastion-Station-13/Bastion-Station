import { afterEach, beforeEach, describe, expect, it, mock } from 'bun:test';
import { act } from 'react';
import { createRoot, type Root } from 'react-dom/client';
import { gameDataAtom, sharedAtom, store } from './events/store';

declare global {
  // react wants this set before act() is used outside of its own test setup
  var IS_REACT_ACT_ENVIRONMENT: boolean;
}
globalThis.IS_REACT_ACT_ENVIRONMENT = true;

// the parts of the page that talk to BYOND are swapped out, the item list is what is under test
mock.module('./interfaces/common/CharacterPreview', () => ({
  CharacterPreview: () => null,
}));
mock.module('./interfaces/PreferencesMenu/names', () => ({
  NameInput: () => null,
}));

let loadoutItems: unknown[] = [];
mock.module('tgui-core/http', () => ({
  fetchRetry: () =>
    Promise.resolve({ json: () => Promise.resolve(loadoutItems) }),
}));

const { LoadoutManager } = await import(
  './interfaces/PreferencesMenu/LoadoutPage'
);

const item = (name: string, extra: Record<string, unknown> = {}) => ({
  name,
  path: `/obj/item/${name.toLowerCase().replace(/\W+/g, '_')}`,
  is_greyscale: false,
  is_renamable: false,
  is_job_restricted: false,
  is_donator_only: false,
  is_ckey_whitelisted: false,
  ...extra,
});

// deliberately out of order, mixed case, numbers and an accent
const HEAD_ITEMS = [
  'Zebra Hat',
  'apple hat',
  'Banana Hat',
  'hat 10',
  'Hat 2',
  'hat 1',
  'Éclair Cap',
].map((name) => item(name));
const HIDDEN = item('Hidden Item');
const UNUSUALS = [
  item('Zap', { unusual_placement: 'zap' }),
  item('Alpha', { unusual_placement: 'alpha' }),
];

let container: HTMLDivElement;
let root: Root;

const render = async (tab: string) => {
  store.set(sharedAtom, { tabs: tab });
  await act(async () => {
    root.render(<LoadoutManager />);
    await Promise.resolve();
    await Promise.resolve();
  });
  await act(async () => {
    root.render(<LoadoutManager />);
  });
};

// first cell of a row is the icon, the name comes after it
const nameCell = (row: Element) =>
  row.querySelectorAll('[class*="Stack__item"]')[1];

const shownNames = () =>
  Array.from(container.querySelectorAll('tr')).map((row) =>
    nameCell(row)?.textContent?.trim(),
  );

describe('LoadoutManager item order', () => {
  beforeEach(() => {
    loadoutItems = [
      {
        name: 'Head',
        title: 'Head Slot Items',
        contents: [...HEAD_ITEMS, HIDDEN],
      },
    ];
    store.set(gameDataAtom, {
      selected_loadout: [],
      selected_unusuals: [],
      user_is_donator: false,
      available_items: HEAD_ITEMS.map((entry) => entry.path),
      extra_tabs: [
        { name: 'Unusuals', title: 'Unusual effects', contents: UNUSUALS },
      ],
      character_preview_view: 'preview',
    });
    container = document.createElement('div');
    document.body.appendChild(container);
    root = createRoot(container);
  });

  afterEach(async () => {
    await act(async () => root.unmount());
    container.remove();
  });

  it('lists the items of a category alphabetically', async () => {
    await render('Head');
    expect(shownNames()).toEqual([
      'apple hat',
      'Banana Hat',
      'Éclair Cap',
      'hat 1',
      'Hat 2',
      'hat 10',
      'Zebra Hat',
    ]);
  });

  it('still hides items the player is not allowed to see', async () => {
    await render('Head');
    expect(shownNames()).not.toContain('Hidden Item');
  });

  it('also sorts the extra categories that come from the server per player', async () => {
    await render('Unusuals');
    expect(shownNames()).toEqual(['Alpha', 'Zap']);
  });
});

describe('LoadoutManager item icons', () => {
  const FILE_ICON = item('Plain Hat', {
    icon: 'icons/obj/hats.dmi',
    icon_state: 'plain_hat',
  });
  const SHEET_ICON = item('Grey Hat', { icon: 'objitemgreyhat' });
  const NO_ICON = item('Mystery Hat');
  const ITEMS = [FILE_ICON, SHEET_ICON, NO_ICON];
  const rowOf = (name: string) =>
    Array.from(container.querySelectorAll('tr')).find(
      (row) => nameCell(row)?.textContent?.trim() === name,
    ) as Element;

  // DmIcon looks the icon file up in this map
  const globals = globalThis as { Byond?: unknown };
  let byond: unknown;
  beforeEach(() => {
    byond = globals.Byond;
    globals.Byond = { iconRefMap: { 'icons/obj/hats.dmi': '[0xc000001]' } };
    loadoutItems = [
      { name: 'Head', title: 'Head Slot Items', contents: ITEMS },
    ];
    store.set(gameDataAtom, {
      selected_loadout: [],
      selected_unusuals: [],
      user_is_donator: false,
      available_items: ITEMS.map((entry) => entry.path),
      extra_tabs: [],
      character_preview_view: 'preview',
    });
    container = document.createElement('div');
    document.body.appendChild(container);
    root = createRoot(container);
  });

  afterEach(async () => {
    await act(async () => root.unmount());
    container.remove();
    globals.Byond = byond;
  });

  it('draws an item from its icon file', async () => {
    await render('Head');
    const image = rowOf('Plain Hat').querySelector('img');
    expect(image?.getAttribute('src')).toStartWith(
      '[0xc000001]?state=plain_hat',
    );
  });

  it('draws greyscale items from the loadout spritesheet', async () => {
    await render('Head');
    const sprite = rowOf('Grey Hat').querySelector(
      '.loadout_items32x32.objitemgreyhat',
    );
    expect(sprite).not.toBeNull();
    expect(rowOf('Grey Hat').querySelector('img')).toBeNull();
  });

  it('shows a larger icon while hovering over the name', async () => {
    await render('Head');
    const name = nameCell(rowOf('Plain Hat')).firstElementChild as Element;
    const iconWidths = () =>
      Array.from(document.querySelectorAll('img')).map((image) =>
        Number.parseFloat(image.style.width),
      );
    expect(iconWidths().length).toBe(1);
    await act(async () => {
      name.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
      // the tooltip opens once the pointer has moved over the name and rested
      const move = new MouseEvent('mousemove', { bubbles: true });
      Object.defineProperty(move, 'movementX', { value: 5 });
      Object.defineProperty(move, 'movementY', { value: 5 });
      name.dispatchEvent(move);
      await new Promise((resolve) => setTimeout(resolve, 300));
    });
    const [small, large] = iconWidths();
    expect(iconWidths().length).toBe(2);
    expect(large).toBeCloseTo(small * 2, 2);
  });

  it('leaves the icon empty for an item that has none', async () => {
    await render('Head');
    const row = rowOf('Mystery Hat');
    expect(row.querySelector('img')).toBeNull();
    expect(row.querySelector('[class*="loadout_items32x32"]')).toBeNull();
  });
});
