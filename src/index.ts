import { registerPlugin } from '@capacitor/core';

import type { CapacitorWalletAccessPlugin } from './definitions';

const CapacitorWalletAccess = registerPlugin<CapacitorWalletAccessPlugin>('CapacitorWalletAccess', {
  web: () => import('./web').then(m => new m.CapacitorWalletAccessWeb()),
});

export * from './definitions';
export { CapacitorWalletAccess };
