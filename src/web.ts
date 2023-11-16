import { WebPlugin } from '@capacitor/core';
import type { WalletAccessPlugin } from './definitions';

export class WalletAccessWeb extends WebPlugin implements WalletAccessPlugin {

  // Test Function (Control)
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  // Retrieves Wallet (Array of PKPasses)
  async getWallet(options: {value: string[]}): Promise<{ cards: any[] }> {
    console.log("Inside of getWallet in cap plugin...")
    console.log('Get Wallet Params', options.value)
    return {
      cards: [],
    }
  }

  async generatePass(options: {
    serialNumberInput: string,
    organizerNameInput: string,

    passCreationURL: string,
    passDownloadPath?: string,
    passStoredAs?: string,
    passAuthorizationKey?: string,
    webStorageInput: string,
    usesSerialNumberinDownload: boolean,

    passObject: object,

    firebaseStorageUrl?: string,
    googleAppID?: string,
    gcmSenderID?: string,

    awsRegion?: string,
    awsBucketName?: string,

  }): Promise<{ newPass: string }> {
    console.log("Inside createNewPass")
    console.log("Params: ", options)
    return{
      newPass: ""
    }
  }

  // async updatePass(options: {
  //   serialNumberInput: string,
  //   organizerNameInput: string,

  //   passCreationURL: string,
  //   webStroageInput: string,
  //   passDownloadURL: string,
  //   userSerialNumberinDownload: string,

  //   headerValues: string[],
  //   headerLabels: string[],

  //   primaryValues: string[],
  //   primaryLabels: string[],

  //   secondaryValues: string[],
  //   secondaryLabels: string[],

  //   auxiliaryValues: string[],
  //   auxiliaryLabels: string[],
  // }): Promise<{ newPass: string }> {
  //   console.log("Inside updatePass")
  //   console.log("Params: ", options)
  //   return{
  //     newPass: ""
  //   }
  // }

}
