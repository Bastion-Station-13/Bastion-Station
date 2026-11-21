import type { BooleanLike } from 'common/react';
import { createSearch } from 'common/string';
import { useState } from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, Input, Section, Table } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { StationMap } from './common/StationMap';
import {
  type MapFocus,
  type StationMapData,
  tileToPercent,
} from './common/stationMapUtils';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

const SORT_NAMES = {
  ijob: 'Job',
  name: 'Name',
  area: 'Position',
  health: 'Vitals',
};

const STAT_LIVING = 0;
const STAT_DEAD = 4;

const SORT_OPTIONS = ['health', 'ijob', 'name', 'area'];

export const jobIsHead = (jobId: number) => jobId % 10 === 0;

export const jobToColor = (jobId) => {
  if (jobId === 0) {
    return COLORS.department.captain;
  }
  if (jobId >= 10 && jobId < 20) {
    return COLORS.department.security;
  }
  if (jobId === 998) {
    return COLORS.department.prisoner;
  }
  if (jobId >= 20 && jobId < 30) {
    return COLORS.department.medbay;
  }
  if (jobId >= 30 && jobId < 40) {
    return COLORS.department.science;
  }
  if (jobId >= 40 && jobId < 50) {
    return COLORS.department.engineering;
  }
  if (jobId >= 50 && jobId < 60) {
    return COLORS.department.cargo;
  }
  if (jobId >= 60 && jobId < 200) {
    return COLORS.department.service;
  }
  if (jobId >= 200 && jobId < 240) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

const statToIcon = (life_status: number) => {
  switch (life_status) {
    case STAT_LIVING:
      return 'heart';
    case STAT_DEAD:
      return 'skull';
  }
  return 'heartbeat';
};

const healthSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.life_status > b.life_status) return -1;
  if (a.life_status < b.life_status) return 1;
  if (a.health < b.health) return -1;
  if (a.health > b.health) return 1;
  return 0;
};

const areaSort = (a: CrewSensor, b: CrewSensor) => {
  a.area ??= '~';
  b.area ??= '~';
  if (a.area < b.area) return -1;
  if (a.area > b.area) return 1;
  return 0;
};

const healthToAttribute = (
  oxy: number,
  tox: number,
  burn: number,
  brute: number,
  attributeList: string[],
) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return attributeList[level];
};

type HealthStatProps = {
  type: string;
  value: number;
};

const HealthStat = (props: HealthStatProps) => {
  const { type, value } = props;
  return (
    <Box inline width={2} color={COLORS.damageType[type]} textAlign="center">
      {value}
    </Box>
  );
};

export const CrewConsoleNova = () => {
  const { data } = useBackend<CrewConsoleData>();
  const { map, sensors, z } = data;

  const [showMap, setShowMap] = useState(true);
  const [hoveredRef, setHoveredRef] = useState<string | null>(null);
  const [focus, setFocus] = useState<MapFocus>();

  const mapVisible = !!map && showMap;

  const track = (sensor: CrewSensor) => {
    const position = getPosition(map, z, sensor);
    if (!position) {
      return;
    }
    setShowMap(true);
    setFocus(position);
  };

  const table = (
    <CrewTable
      hoveredRef={hoveredRef}
      setHoveredRef={setHoveredRef}
      mapShown={mapVisible}
      toggleMap={map ? () => setShowMap(!showMap) : undefined}
      onTrack={track}
    />
  );

  if (!mapVisible) {
    return (
      <Window title="Crew Monitor" width={600} height={600}>
        <Window.Content scrollable>
          <Section minHeight="540px">{table}</Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="Crew Monitor" width={1100} height={720}>
      <Window.Content>
        <Flex height="100%" gap={1}>
          <Flex.Item
            width="520px"
            shrink={0}
            height="100%"
            style={{ overflowY: 'auto' }}
          >
            <Section>{table}</Section>
          </Flex.Item>
          <Flex.Item grow height="100%">
            <StationMap map={map} focus={focus}>
              {(zoom) =>
                sensors.map((sensor) => (
                  <CrewBlip
                    key={sensor.ref}
                    sensor={sensor}
                    map={map}
                    mapZ={z}
                    zoom={zoom}
                    hovered={hoveredRef === sensor.ref}
                    setHoveredRef={setHoveredRef}
                    onTrack={track}
                  />
                ))
              }
            </StationMap>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

/** A sensor's place on the map, if it is on the level the map is of */
const getPosition = (
  map: StationMapData | null | undefined,
  z: number,
  sensor: CrewSensor,
) => {
  if (!map || map.z !== z || sensor.x === undefined || sensor.y === undefined) {
    return undefined;
  }
  return tileToPercent(map, sensor.x, sensor.y);
};

const SPRITE_SIZE = 8;

// The job icons are 8x8 sprites of the job_icons spritesheet, shown bigger
const JobIcon = (props: { iconClass: string; size?: number }) => {
  const { iconClass, size = 16 } = props;
  return (
    <Box inline verticalAlign="middle" width={`${size}px`} height={`${size}px`}>
      <Box
        className={iconClass}
        style={{
          transform: `scale(${size / SPRITE_SIZE})`,
          transformOrigin: 'top left',
          imageRendering: 'pixelated',
        }}
      />
    </Box>
  );
};

type CrewBlipProps = {
  sensor: CrewSensor;
  map: StationMapData;
  mapZ: number;
  zoom: number;
  hovered: boolean;
  setHoveredRef: (ref: string | null) => void;
  onTrack: (sensor: CrewSensor) => void;
};

const CrewBlip = (props: CrewBlipProps) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { sensor, map, mapZ, zoom, hovered, setHoveredRef, onTrack } = props;
  const position = getPosition(map, mapZ, sensor);
  if (!position) {
    return null;
  }

  return (
    <div
      onClick={(event) => {
        event.stopPropagation();
        if (data.link_allowed) {
          act('select_person', { ref: sensor.ref });
          return;
        }
        onTrack(sensor);
      }}
      onMouseEnter={() => setHoveredRef(sensor.ref)}
      onMouseLeave={() => setHoveredRef(null)}
      style={{
        position: 'absolute',
        left: `${position.left}%`,
        bottom: `${position.bottom}%`,
        // the icon stays the same size on screen however far the map is zoomed
        transform: `translate(-50%, 50%) scale(${1 / zoom})`,
        transformOrigin: 'center center',
        cursor: 'pointer',
        zIndex: hovered ? 20 : 2,
      }}
    >
      <div
        style={{
          opacity: hovered ? 1 : 0.85,
          transform: hovered ? 'scale(1.25)' : 'scale(1)',
          transition: 'transform 0.1s ease-in-out',
        }}
      >
        {sensor.job_icon ? (
          <JobIcon iconClass={sensor.job_icon} />
        ) : (
          <Box
            width="8px"
            height="8px"
            backgroundColor={jobToColor(sensor.ijob)}
            style={{ borderRadius: '50%', border: '1px solid #000000' }}
          />
        )}
      </div>
    </div>
  );
};

type CrewSensor = {
  name: string;
  assignment: string | undefined;
  ijob: number;
  is_robot: any;
  life_status: number;
  oxydam: number;
  toxdam: number;
  burndam: number;
  brutedam: number;
  area: string | undefined;
  health: number;
  ref: string;
  job_icon?: string;
  x?: number;
  y?: number;
};

type CrewConsoleData = {
  sensors: CrewSensor[];
  link_allowed: BooleanLike;
  z: number;
  map?: StationMapData | null;
};

type CrewTableProps = {
  hoveredRef: string | null;
  setHoveredRef: (ref: string | null) => void;
  mapShown: boolean;
  toggleMap?: () => void;
  onTrack: (sensor: CrewSensor) => void;
};

const CrewTable = (props: CrewTableProps) => {
  const { hoveredRef, setHoveredRef, mapShown, toggleMap, onTrack } = props;
  const { data } = useBackend<CrewConsoleData>();
  const { sensors } = data;

  const [sortAsc, setSortAsc] = useLocalState<boolean>('sortAsc', true);
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    'searchQuery',
    '',
  );
  const [sortBy, setSortBy] = useLocalState<string>('sortBy', SORT_OPTIONS[0]);
  const [filterTracking, setfilterTracking] = useLocalState<boolean>(
    'filterTracking',
    false,
  );

  const cycleSortBy = () => {
    let idx = SORT_OPTIONS.indexOf(sortBy) + 1;
    if (idx === SORT_OPTIONS.length) idx = 0;
    setSortBy(SORT_OPTIONS[idx]);
  };

  // the console can track people for an AI, everyone else needs the map for it
  const canTrack = !!data.link_allowed || !!toggleMap;

  const nameSearch = createSearch(
    searchQuery,
    (crew: CrewSensor) => crew.name + crew.assignment,
  );

  const sorted = sensors
    .filter(nameSearch)
    .filter(
      (sensor) =>
        !filterTracking || (sensor.area !== '~' && sensor.area !== undefined),
    )
    .sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return sortAsc ? +(a.name > b.name) : +(b.name > a.name);
        case 'ijob':
          return sortAsc ? a.ijob - b.ijob : b.ijob - a.ijob;
        case 'health':
          return sortAsc ? healthSort(a, b) : healthSort(b, a);
        case 'area':
          return sortAsc ? areaSort(a, b) : areaSort(b, a);
        default:
          return 0;
      }
    });

  return (
    <Section
      title={
        <>
          <Button onClick={cycleSortBy}>{SORT_NAMES[sortBy]}</Button>
          <Button onClick={() => setSortAsc(!sortAsc)}>
            <Icon
              style={{ marginLeft: '2px' }}
              name={sortAsc ? 'chevron-up' : 'chevron-down'}
            />
          </Button>
          <Input
            placeholder="Search for name..."
            onChange={(value) => setSearchQuery(value)}
          />
          <Button onClick={() => setfilterTracking(!filterTracking)}>
            {filterTracking ? (
              <Icon style={{ marginLeft: '2px' }} name="location-dot" />
            ) : (
              'All'
            )}
          </Button>
          {!!toggleMap && (
            <Button
              icon={mapShown ? 'chevron-right' : 'chevron-left'}
              tooltip={mapShown ? 'Hide map' : 'Show map'}
              selected={mapShown}
              onClick={toggleMap}
            />
          )}
        </>
      }
    >
      <Table>
        <Table.Row>
          <Table.Cell bold>Name</Table.Cell>
          <Table.Cell bold collapsing textAlign="center" />
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Vitals
          </Table.Cell>
          <Table.Cell bold textAlign="center">
            Position
          </Table.Cell>
          {canTrack && (
            <Table.Cell bold collapsing textAlign="center">
              Tracking
            </Table.Cell>
          )}
        </Table.Row>
        {sorted.map((sensor) => (
          <CrewTableEntry
            sensor_data={sensor}
            key={sensor.ref}
            hovered={hoveredRef === sensor.ref}
            setHoveredRef={setHoveredRef}
            canTrack={canTrack}
            onTrack={onTrack}
          />
        ))}
      </Table>
    </Section>
  );
};

type CrewTableEntryProps = {
  sensor_data: CrewSensor;
  hovered: boolean;
  setHoveredRef: (ref: string | null) => void;
  canTrack: boolean;
  onTrack: (sensor: CrewSensor) => void;
};

const CrewTableEntry = (props: CrewTableEntryProps) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { link_allowed, map, z } = data;
  const { sensor_data, hovered, setHoveredRef, canTrack, onTrack } = props;
  const {
    name,
    assignment,
    ijob,
    is_robot,
    life_status,
    oxydam,
    toxdam,
    burndam,
    brutedam,
    area,
    ref,
    job_icon,
  } = sensor_data;

  return (
    <Table.Row
      className="candystripe"
      onMouseOver={() => setHoveredRef(ref)}
      onMouseLeave={() => setHoveredRef(null)}
      style={{
        backgroundColor: hovered ? 'rgba(255, 255, 255, 0.12)' : undefined,
      }}
    >
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        {!!job_icon && (
          <>
            <JobIcon iconClass={job_icon} />{' '}
          </>
        )}
        {name}
        {assignment !== undefined ? ` (${assignment})` : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {is_robot ? <Icon name="wrench" color="#B7410E" size={1} /> : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Icon
            name={statToIcon(life_status)}
            color={healthToAttribute(
              oxydam,
              toxdam,
              burndam,
              brutedam,
              HEALTH_COLOR_BY_LEVEL,
            )}
            size={1}
          />
        ) : life_status !== STAT_DEAD ? (
          <Icon name="heart" color="#17d568" size={1} />
        ) : (
          <Icon name="skull" color="#801308" size={1} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Box inline>
            <HealthStat type="oxy" value={oxydam} />
            {'/'}
            <HealthStat type="toxin" value={toxdam} />
            {'/'}
            <HealthStat type="burn" value={burndam} />
            {'/'}
            <HealthStat type="brute" value={brutedam} />
          </Box>
        ) : life_status !== STAT_DEAD ? (
          'Alive'
        ) : (
          'Dead'
        )}
      </Table.Cell>
      <Table.Cell>
        {area !== '~' && area !== undefined ? (
          area
        ) : (
          <Icon name="question" color="#ffffff" size={1} />
        )}
      </Table.Cell>
      {canTrack && (
        <Table.Cell collapsing>
          <Button
            disabled={!link_allowed && !getPosition(map, z, sensor_data)}
            onClick={() =>
              link_allowed
                ? act('select_person', {
                    ref: ref,
                  })
                : onTrack(sensor_data)
            }
          >
            Track
          </Button>
        </Table.Cell>
      )}
    </Table.Row>
  );
};
