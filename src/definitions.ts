export interface WalletAccessPlugin {

  // Echo Function 
  echo(options: { value: string }): 
    Promise<{ value: string }>;

  // Get Wallet Function
  getWallet(options: {value: string[]}): 
    Promise<{ cards: any[] }>

  // Creates a Pass
  createNewPass(options: {
    headerValues: string[],
    headerLabels: string[],

    primaryValues: string[],
    primaryLabels: string[],

    secondaryValues: string[],
    secondaryLabels: string[],

    auxiliaryValues: string[],
    auxiliaryLabels: string[],

    serialNumer: string,
    organizerName: string,
    passURLInput: string

  }): 
    Promise<{ value: string}>
}
