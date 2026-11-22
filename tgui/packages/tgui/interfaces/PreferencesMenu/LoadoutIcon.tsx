import { classes } from 'common/react';
import { Box, DmIcon, Icon } from '../../components';

type Props = {
  icon?: string;
  icon_state?: string;
  size?: number;
};

// Greyscale items have no icon state, their icon is a class of the loadout_items spritesheet
export const LoadoutIcon = (props: Props) => {
  const { icon, icon_state, size = 32 } = props;
  const length = `${size}px`;

  if (icon && icon_state) {
    return (
      <DmIcon
        icon={icon}
        icon_state={icon_state}
        verticalAlign="middle"
        width={length}
        height={length}
        fallback={<Icon name="spinner" size={size / 16} spin />}
      />
    );
  }

  return (
    <Box inline verticalAlign="middle" width={length} height={length}>
      {!!icon && (
        <Box
          className={classes(['loadout_items32x32', icon])}
          style={{
            transform: `scale(${size / 32})`,
            transformOrigin: 'top left',
            imageRendering: 'pixelated',
          }}
        />
      )}
    </Box>
  );
};
