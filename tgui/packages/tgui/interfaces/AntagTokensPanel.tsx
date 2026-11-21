import { useEffect } from 'react';
import { useLocalState,useBackend } from 'tgui/backend';
import {
  Button,
  Collapsible,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type AntagPanelData = {
    clients : string[];

}

export const AntagTokensPanel = (props) =>
{
  const { act, data } = useBackend<AntagPanelData>();
  const ckeys = data.clients || [];
  const [selected, setSelected] = useLocalState<string>(
      'selected',
      ""
    );
  return (
    <Window title="Antag Token Adjuster">
        <Window.Content scrollable>
        <Stack fill vertical>
            <Stack.Item>
                <LabeledList>
                    {ckeys.map((item) =>
                    (
                        <LabeledList.Item>
                            <Button onClick={() => {setSelected(item)}}>{item}</Button>
                        </LabeledList.Item>
                    )
                    )}
                </LabeledList>
            </Stack.Item>
            <Stack.Item>
                <Input id='SelectedCKEY' placeholder='Select one from the list or type in here manually' value={selected} onChange={val => (setSelected(val))}>

                </Input>
            </Stack.Item>
            <Stack.Item>
                <Button backgroundColor='green' onClick={() => {act("submit", {ckey: selected})}}>Next</Button>
            </Stack.Item>
            <Stack.Item>
                <Button backgroundColor='red' onClick={() => close()}>Cancel</Button>
            </Stack.Item>
        </Stack>
        </Window.Content>
    </Window>
  )
}
