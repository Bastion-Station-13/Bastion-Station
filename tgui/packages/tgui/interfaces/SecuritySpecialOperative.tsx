import { useBackend, useLocalState } from '../backend';
import { Box, Button, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type Category = {
  name: string;
  points: number;
  max_items: number;
  selected_items: number;
};

type KitItem = {
  id: string;
  name: string;
  desc: string;
  category: string;
  cost: number;
};

type SelectedItem = {
  index: number;
  name: string;
  category: string;
  cost: number;
};

type ShopData = {
  categories: Category[];
  items: KitItem[];
  selected_items: SelectedItem[];
};

export const SecuritySpecialOperative = () => {
  const { act, data } = useBackend<ShopData>();
  const { categories, items, selected_items } = data;
  const [selectedCategory, setSelectedCategory] = useLocalState(
    'category',
    categories[0]?.name || 'Lethal',
  );
  const category = categories.find((entry) => entry.name === selectedCategory);
  const categoryItems = items.filter(
    (item) => item.category === selectedCategory,
  );

  return (
    <Window width={780} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="190px">
            <Section title="Requisition points" fill>
              <Tabs vertical>
                {categories.map((entry) => (
                  <Tabs.Tab
                    key={entry.name}
                    selected={entry.name === selectedCategory}
                    onClick={() => setSelectedCategory(entry.name)}
                  >
                    <Stack justify="space-between">
                      <Stack.Item>{entry.name}</Stack.Item>
                      <Stack.Item>
                        {entry.points} pt
                      </Stack.Item>
                    </Stack>
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title={selectedCategory}
              buttons={
                category && (
                  <Box>
                    {category.selected_items}/{category.max_items} selected
                  </Box>
                )
              }
              fill
              scrollable
            >
              {categoryItems.length ? (
                categoryItems.map((item) => (
                  <Section
                    key={item.id}
                    title={item.name}
                    buttons={
                      <Button
                        disabled={
                          !category ||
                          category.points < item.cost ||
                          category.selected_items >= category.max_items
                        }
                        onClick={() => act('add', { id: item.id })}
                      >
                        {item.cost} pt
                      </Button>
                    }
                  >
                    {item.desc}
                  </Section>
                ))
              ) : (
                <NoticeBox>No equipment is available in this category.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item width="220px">
            <Section title="Selected equipment" fill scrollable>
              {selected_items.length ? (
                selected_items.map((item) => (
                  <Stack key={item.index} align="center">
                    <Stack.Item grow>
                      <Box bold>{item.name}</Box>
                      <Box color="label">
                        {item.category} - {item.cost} pt
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="times"
                        onClick={() => act('remove', { index: item.index })}
                      />
                    </Stack.Item>
                  </Stack>
                ))
              ) : (
                <NoticeBox>No equipment selected.</NoticeBox>
              )}
              <Button
                fluid
                color="good"
                mt={1}
                disabled={!selected_items.length}
                onClick={() => act('checkout')}
              >
                Checkout and destroy device
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
