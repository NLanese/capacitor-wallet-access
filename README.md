# capacitor-wallet-access

Used to gain access to a user's wallet on their device. This allows access to the cards, passes, or tickets a user will have in their wallet, but this does NOT include the capacity to create new passes

## Install

```bash
npm install capacitor-wallet-access
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`getWallet(...)`](#getwallet)
* [`generatePass(...)`](#generatepass)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### getWallet(...)

```typescript
getWallet(options: { value: string[]; }) => Promise<{ cards: any[]; }>
```

| Param         | Type                              |
| ------------- | --------------------------------- |
| **`options`** | <code>{ value: string[]; }</code> |

**Returns:** <code>Promise&lt;{ cards: any[]; }&gt;</code>

--------------------


### generatePass(...)

```typescript
generatePass(options: { serialNumberInput: string; organizerNameInput: string; passCreationURL: string; passDownloadURL: string; passAuthorizationKey: string; webStroageInput: string; usesSerialNumberinDownload: boolean; headerValues: string[]; headerLabels: string[]; primaryValues: string[]; primaryLabels: string[]; secondaryValues: string[]; secondaryLabels: string[]; auxiliaryValues: string[]; auxiliaryLabels: string[]; }) => Promise<{ newPass: string; }>
```

| Param         | Type                                                                                                                                                                                                                                                                                                                                                                                                                                |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ serialNumberInput: string; organizerNameInput: string; passCreationURL: string; passDownloadURL: string; passAuthorizationKey: string; webStroageInput: string; usesSerialNumberinDownload: boolean; headerValues: string[]; headerLabels: string[]; primaryValues: string[]; primaryLabels: string[]; secondaryValues: string[]; secondaryLabels: string[]; auxiliaryValues: string[]; auxiliaryLabels: string[]; }</code> |

**Returns:** <code>Promise&lt;{ newPass: string; }&gt;</code>

--------------------

</docgen-api>
