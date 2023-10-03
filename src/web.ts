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

  async createNewPass(options: {
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
  }): Promise<{ newPass: string }> {
    console.log("Inside createNewPass")
    return{
      newPass: ""
    }
  }

  async updatePass(options: {
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
  }): Promise<{ newPass: string }> {
    console.log("Inside updatePass")
    return{
      newPass: ""
    }
  }

}
