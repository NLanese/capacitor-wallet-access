import { WebPlugin } from '@capacitor/core';

import type { WalletAccessPlugin } from './definitions';

export class WalletAccessWeb extends WebPlugin implements WalletAccessPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async getWallet(): Promise<{ cards: any[] }> {
    console.log("Inside of getWallet in cap plugin...")
    return {
      cards: []
    }
  }
}
