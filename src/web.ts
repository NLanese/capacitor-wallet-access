import { WebPlugin } from '@capacitor/core';

import type { CapacitorWalletAccessPlugin } from './definitions';

export class CapacitorWalletAccessWeb extends WebPlugin implements CapacitorWalletAccessPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
