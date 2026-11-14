const collator = new Intl.Collator('en', {
  sensitivity: 'base',
  numeric: true,
});

/**
 * Sorts loadout items by name, ignoring case and accents, with numbers sorted
 * as numbers (Plushie 2 comes before Plushie 10). Returns a new array.
 */
export function sortLoadoutItems<T extends { name: string; path?: string }>(
  items: T[],
): T[] {
  return [...items].sort(
    (a, b) =>
      collator.compare(a.name, b.name) ||
      (a.path ?? '').localeCompare(b.path ?? ''),
  );
}
