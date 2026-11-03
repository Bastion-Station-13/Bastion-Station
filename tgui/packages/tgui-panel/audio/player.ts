/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import Hls from 'hls.js';
import { createLogger } from 'tgui/logging';
import { defaultSettings } from '../settings/atoms';

const logger = createLogger('AudioPlayer');

// Not every browser can play these on its own, SoundCloud only gives them out
const HLS_URL = /\.m3u8(?:$|[?#])/i;

type AudioOptions = {
  pitch?: number;
  start?: number;
  end?: number;
};

function isProtectedError(error: ErrorEvent): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'isTrusted' in error &&
    error.isTrusted
  );
}

export class AudioPlayer {
  element: HTMLAudioElement | null;
  hls: Hls | null;
  options: AudioOptions;
  volume: number;

  onPlaySubscribers: (() => void)[];
  onStopSubscribers: (() => void)[];

  constructor() {
    this.element = null;
    this.hls = null;
    this.volume = defaultSettings.adminMusicVolume;

    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
  }

  destroy(): void {
    this.hls?.destroy();
    this.hls = null;
    this.element = null;
  }

  play(url: string, options: AudioOptions = {}): void {
    if (this.element) {
      this.stop();
    }

    this.options = options;

    const useHls = HLS_URL.test(url) && Hls.isSupported();
    const audio = useHls ? new Audio() : new Audio(url);
    if (!audio) {
      logger.log('failed to create audio element');
      return;
    }
    this.element = audio;

    audio.volume = this.volume;
    audio.playbackRate = this.options.pitch || 1;

    if (useHls) {
      const hls = new Hls({ startPosition: this.options.start ?? -1 });
      this.hls = hls;
      hls.on(Hls.Events.ERROR, (_event, data) => {
        if (!data.fatal) {
          return;
        }
        logger.log('hls error:', data.type, data.details);
        this.stop();
      });
      hls.loadSource(url);
      hls.attachMedia(audio);
    } else if (this.options.start) {
      audio.currentTime = this.options.start;
    }

    logger.log('playing', url, options);

    audio.addEventListener('ended', () => {
      logger.log('ended');
      this.stop();
    });

    audio.addEventListener('error', (error) => {
      if (isProtectedError(error)) {
        Byond.sendMessage('audio/protected');
      }
      logger.log('playback error:', JSON.stringify(error));
      this.stop();
    });

    if (this.options.end) {
      audio.addEventListener('timeupdate', () => {
        if (
          this.options.end &&
          this.options.end > 0 &&
          audio.currentTime >= this.options.end
        ) {
          this.stop();
        }
      });
    }

    audio.play()?.catch(() => {
      // no error is passed here, it's sent to the event listener
      logger.log('playback failed');
    });

    this.onPlaySubscribers.forEach((subscriber) => {
      subscriber();
    });
  }

  stop(): void {
    if (!this.element) return;

    logger.log('stopping');

    this.element.pause();
    this.destroy();

    this.onStopSubscribers.forEach((subscriber) => {
      subscriber();
    });
  }

  setVolume(volume: number): void {
    this.volume = volume;

    if (!this.element) return;

    this.element.volume = volume;
  }

  onPlay(subscriber: () => void): void {
    this.onPlaySubscribers.push(subscriber);
  }

  onStop(subscriber: () => void): void {
    this.onStopSubscribers.push(subscriber);
  }
}
