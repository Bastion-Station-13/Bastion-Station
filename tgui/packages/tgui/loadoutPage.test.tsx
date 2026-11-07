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

const shownNames = () =>
  Array.from(container.querySelectorAll('tr')).map((row) =>
    row.querySelector('[class*="Stack__item"]')?.textContent?.trim(),
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
