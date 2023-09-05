import { registerPlugin } from '@capacitor/core';

import type { WalletAccessPlugin } from './definitions';

const WalletAccess = registerPlugin<WalletAccessPlugin>('WalletAccess', {
  web: () => import('./web').then(m => new m.WalletAccessWeb()),
});

export * from './definitions';
export { WalletAccess };
