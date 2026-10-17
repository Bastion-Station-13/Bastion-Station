import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

export const ARCFIEND_MECHANICAL_DESCRIPTION = multiline`
      Drain power from the station and its crew, then spend it on new powers
      and upgrades.
   `;

const Arcfiend: Antagonist = {
  key: 'arcfiend',
  name: 'Arcfiend',
  description: [
    multiline`
      A human who has been in contact with reprogrammed nanites, turning their
      body into a living conductor, allowing them to feed on electricity.
    `,
    ARCFIEND_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Arcfiend;
