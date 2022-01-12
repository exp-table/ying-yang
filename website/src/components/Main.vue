<script setup>
</script>

<template>
  <div v-if="userL2Address">
    <p>Your Starknet address</p>
    <p>{{userL2Address}}</p>
    <p><button @click="checkBalance">Check my balance</button> | My balance : {{outputs.balance}}</p>
    <p><button @click="transfer">Transfer</button> | <input v-model="inputs.transfer_to" placeholder="recipient" /><input v-model="inputs.transfer_token_id" placeholder="token_id"/></p>
    <p><button @click="ownerOf">Query owner</button> <input v-model="inputs.owner_of" placeholder="token_id" /> | Owner : {{outputs.owner_of}}</p>
  </div>
  <div v-else>
    <p>You need to be connected with your ArgentX wallet.</p>
    <button @click="connectL2">Connect to Starknet</button>
  </div>
  <hr>
  <div v-if="userL1Address && userL2Address">
    <p>Your Ethereum address</p>
    <p>{{userL1Address}}</p>
    <p><b>Pay 1 wei and the NFT will be minted automatically on Starknet. Might takes a few minutes.</b></p>
    <button @click="pay">Pay 1 wei</button>
  </div>
  <div v-else>
    <button @click="connectL1">Connect to Ethereum</button>
  </div>

</template>

<script>
import { getStarknet } from "@argent/get-starknet";
import { compileCalldata, stark, number } from 'starknet';
const { getSelectorFromName } = stark;
import { Contract, providers } from "ethers";
import Web3Modal from "web3modal";

import abi from '../assets/abi.json';

const L2_CONTRACT_ADDRESS = "0x07a275b5d579275ffe4ac0bb4e2767119cf771d76c7c1f86c9c99605e5090242";

export default {
  name: 'Main',
  data() {
    return {
      starknet : undefined,
      userL2Address : undefined,
      userL1Address : undefined,
      signer : undefined,
      vendingMachine : undefined,
      inputs : {
        transfer_to : undefined,
        transfer_token_id: undefined,
        owner_of: undefined
      },
      outputs : {
        owner_of : undefined,
        balance : undefined
      }
    }
  },
  methods : {
    async connectL2() {
      this.starknet = getStarknet({ showModal: true });
      const [userWalletContractAddress] = await this.starknet.enable(); // may throws when no extension is detected

      // check if connection was successful
      if(this.starknet.isConnected) {
        this.userL2Address = userWalletContractAddress;
      } else {
        // In case the extension wasn't successfully connected you still have access to a starknet.js Provider to read starknet states and sent anonymous transactions
        console.log("not connected!");
      }
    },
    async connectL1() {
      const providerOptions = {};
      const web3Modal = new Web3Modal({
        network: "goerli", // optional
        cacheProvider: true, // optional
        providerOptions // required
      });
      const instance = await web3Modal.connect();
			const web3Provider = new providers.Web3Provider(instance);
			const signer = await web3Provider.getSigner();
			const address = await signer.getAddress();
      const network = await web3Provider.getNetwork();
      console.log(`Connected to ${network.name}`);
      this.signer = signer;
      this.userL1Address = address;

      this.vendingMachine = new Contract("0xD72dB7540dbEB1011A9b46F123Df5eb8A67c7cC8", abi, signer);
    },

    async pay() {
      this.vendingMachine.pay(this.userL2Address, {value: 1});
    },
    async checkBalance() {
      this.outputs.balance = "loading...";
      const balance = await this.starknet.provider.callContract({
        contract_address: L2_CONTRACT_ADDRESS,
        entry_point_selector: getSelectorFromName("balance_of"),
        calldata: [number.hexToDecimalString(this.userL2Address)]
      });
      this.outputs.balance = parseInt(balance.result[0]);
    },
    async ownerOf() {
      this.outputs.owner_of = "loading...";
      const owner = await this.starknet.provider.callContract({
        contract_address: L2_CONTRACT_ADDRESS,
        entry_point_selector: getSelectorFromName("owner_of"),
        calldata: [""+this.inputs.owner_of]
      });
      this.outputs.owner_of = owner.result[0];
    },
    async transfer() {
      const sanitizedRecipient = number.isHex(this.inputs.transfer_to) ? number.hexToDecimalString(this.inputs.transfer_to) : ""+this.inputs.transfer_to;
      const sanitizedTokenId = number.isHex(this.inputs.inputs.transfer_token_id) ? number.hexToDecimalString(this.inputs.inputs.transfer_token_id) : ""+this.inputs.inputs.transfer_token_id;
      const tx = await this.starknet.signer.invokeFunction(
        L2_CONTRACT_ADDRESS,
        getSelectorFromName("transfer"),
        compileCalldata({
          recipient: sanitizedRecipient,
          token_id: sanitizedTokenId 
        })
      );
    }
  },
  mounted() {
    //
  }
}
</script>

<style scoped>
</style>
