export interface CapacitorWalletAccessPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
