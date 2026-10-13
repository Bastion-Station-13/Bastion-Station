import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

export const ARCFIEND_MECHANICAL_DESCRIPTION = multiline`
      Drain power from the station and its crew, then spend it on electric
      powers and upgrades.
   `;

const Arcfiend: Antagonist = {
  key: 'arcfiend',
  name: 'Arcfiend',
  description: [
    multiline`
      A human whose body was rewritten by conductive nanites. You feed on
      electricity, and the station is full of it.
    `,
    ARCFIEND_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Arcfiend;
