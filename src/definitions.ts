export interface WalletAccessPlugin {

  // Echo Function 
  echo(options: { value: string }): 
    Promise<{ value: string }>;

  // Get Wallet Function
  getWallet(options: {value: string[]}): 
    Promise<{ cards: any[] }>

  // Creates a Pass
  generatePass(options: {
    passConfig: object
    passObject: object,
    storageConfig: object,
    miscData?: object
  }): 
    Promise<{ newPass: string }>
}
