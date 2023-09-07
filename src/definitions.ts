export interface WalletAccessPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  getWallet(): Promise<{cards: any[]}>
}
