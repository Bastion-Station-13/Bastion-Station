import { describe, expect, it } from 'bun:test';
import { sortLoadoutItems } from './interfaces/PreferencesMenu/loadoutSort';

const names = (items: { name: string }[]) => items.map((item) => item.name);

describe('sortLoadoutItems', () => {
  it('sorts by name ignoring case', () => {
    const sorted = sortLoadoutItems([
      { name: 'banana' },
      { name: 'Cherry' },
      { name: 'Apple' },
    ]);
    expect(names(sorted)).toEqual(['Apple', 'banana', 'Cherry']);
  });

  it('ignores accents', () => {
    const sorted = sortLoadoutItems([
      { name: 'Zebra' },
      { name: 'Éclair' },
      { name: 'Eagle' },
    ]);
    expect(names(sorted)).toEqual(['Eagle', 'Éclair', 'Zebra']);
  });

  it('sorts numbers as numbers', () => {
    const sorted = sortLoadoutItems([
      { name: 'Plushie 10' },
      { name: 'Plushie 2' },
      { name: 'Plushie 1' },
    ]);
    expect(names(sorted)).toEqual(['Plushie 1', 'Plushie 2', 'Plushie 10']);
  });

  it('keeps items with the same name in a steady order by path', () => {
    const first = { name: 'Hat', path: '/obj/item/hat/a' };
    const second = { name: 'Hat', path: '/obj/item/hat/b' };
    expect(sortLoadoutItems([second, first])).toEqual([first, second]);
    expect(sortLoadoutItems([first, second])).toEqual([first, second]);
  });

  it('does not change the list it was given', () => {
    const items = [{ name: 'B' }, { name: 'A' }];
    const sorted = sortLoadoutItems(items);
    expect(names(items)).toEqual(['B', 'A']);
    expect(sorted).not.toBe(items);
  });

  it('keeps whatever else is on the items', () => {
    const sorted = sortLoadoutItems([
      { name: 'B', cost: 2 },
      { name: 'A', cost: 1 },
    ]);
    expect(sorted).toEqual([
      { name: 'A', cost: 1 },
      { name: 'B', cost: 2 },
    ]);
  });

  it('copes with an empty list', () => {
    expect(sortLoadoutItems([])).toEqual([]);
  });
});
