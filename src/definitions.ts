export interface WalletAccessPlugin {

  // Echo Function 
  echo(options: { value: string }): 
    Promise<{ value: string }>;

  // Get Wallet Function
  getWallet(options: {value: string[]}): 
    Promise<{ cards: any[] }>

  goToPass(options: {value: string }):
    Promise <void>
}
