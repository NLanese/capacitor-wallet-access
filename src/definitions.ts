export interface WalletAccessPlugin {

  // Echo Function 
  echo(options: { value: string }): 
    Promise<{ value: string }>;

  // Get Wallet Function
  getWallet(options: {value: string[]}): 
    Promise<{ cards: any[] }>

  // Creates a Pass
  generatePass(options: {
    serialNumberInput: string,
    organizerNameInput: string,

    passCreationURL: string,
    passDownloadURL: string,
    passAuthorizationKey: string,
    webStroageInput: string,
    usesSerialNumberinDownload: boolean,

    headerValues: string[],
    headerLabels: string[],

    primaryValues: string[],
    primaryLabels: string[],

    secondaryValues: string[],
    secondaryLabels: string[],

    auxiliaryValues: string[],
    auxiliaryLabels: string[],
  }): 
    Promise<{ newPass: string}>

  // // Updates a Pass
  // updatePass(options: {
  //   headerValues: string[],
  //   headerLabels: string[],

  //   primaryValues: string[],
  //   primaryLabels: string[],

  //   secondaryValues: string[],
  //   secondaryLabels: string[],

  //   auxiliaryValues: string[],
  //   auxiliaryLabels: string[],

  //   serialNumer: string,
  //   organizerName: string,
  //   passURLInput: string
  // }): 
  //   Promise<{ newPass: string}>
}
