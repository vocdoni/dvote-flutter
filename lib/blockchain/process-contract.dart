const _rawContractData = {
  "abi": [
    {
      "inputs": [
        {"internalType": "address", "name": "predecessor", "type": "address"},
        {"internalType": "address", "name": "namespace", "type": "address"}
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "blockNumber",
          "type": "uint256"
        }
      ],
      "name": "Activated",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "blockNumber",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "successor",
          "type": "address"
        }
      ],
      "name": "ActivatedSuccessor",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "processId",
          "type": "bytes32"
        },
        {
          "indexed": false,
          "internalType": "uint16",
          "name": "namespace",
          "type": "uint16"
        }
      ],
      "name": "CensusUpdated",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "namespaceAddr",
          "type": "address"
        }
      ],
      "name": "NamespaceAddressUpdated",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "processId",
          "type": "bytes32"
        },
        {
          "indexed": false,
          "internalType": "uint16",
          "name": "namespace",
          "type": "uint16"
        }
      ],
      "name": "NewProcess",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "processId",
          "type": "bytes32"
        },
        {
          "indexed": false,
          "internalType": "uint16",
          "name": "namespace",
          "type": "uint16"
        },
        {
          "indexed": false,
          "internalType": "uint8",
          "name": "newIndex",
          "type": "uint8"
        }
      ],
      "name": "QuestionIndexUpdated",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "processId",
          "type": "bytes32"
        }
      ],
      "name": "ResultsAvailable",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "processId",
          "type": "bytes32"
        },
        {
          "indexed": false,
          "internalType": "uint16",
          "name": "namespace",
          "type": "uint16"
        },
        {
          "indexed": false,
          "internalType": "enum IProcessStore.Status",
          "name": "status",
          "type": "uint8"
        }
      ],
      "name": "StatusUpdated",
      "type": "event"
    },
    {
      "inputs": [],
      "name": "activate",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "successor", "type": "address"}
      ],
      "name": "activateSuccessor",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "activationBlock",
      "outputs": [
        {"internalType": "uint256", "name": "", "type": "uint256"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"}
      ],
      "name": "get",
      "outputs": [
        {
          "internalType": "uint8[2]",
          "name": "mode_envelopeType",
          "type": "uint8[2]"
        },
        {"internalType": "address", "name": "entityAddress", "type": "address"},
        {
          "internalType": "string[3]",
          "name": "metadata_censusMerkleRoot_censusMerkleTree",
          "type": "string[3]"
        },
        {"internalType": "uint64", "name": "startBlock", "type": "uint64"},
        {"internalType": "uint32", "name": "blockCount", "type": "uint32"},
        {
          "internalType": "enum IProcessStore.Status",
          "name": "status",
          "type": "uint8"
        },
        {
          "internalType": "uint8[5]",
          "name":
              "questionIndex_questionCount_maxCount_maxValue_maxVoteOverwrites",
          "type": "uint8[5]"
        },
        {"internalType": "bool", "name": "uniqueValues", "type": "bool"},
        {
          "internalType": "uint16[3]",
          "name": "maxTotalCost_costExponent_namespace",
          "type": "uint16[3]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"}
      ],
      "name": "getCreationInstance",
      "outputs": [
        {"internalType": "address", "name": "", "type": "address"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "entityAddress", "type": "address"}
      ],
      "name": "getEntityProcessCount",
      "outputs": [
        {"internalType": "uint256", "name": "", "type": "uint256"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "entityAddress", "type": "address"},
        {"internalType": "uint16", "name": "namespace", "type": "uint16"}
      ],
      "name": "getNextProcessId",
      "outputs": [
        {"internalType": "bytes32", "name": "", "type": "bytes32"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"}
      ],
      "name": "getParamsSignature",
      "outputs": [
        {"internalType": "bytes32", "name": "", "type": "bytes32"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "entityAddress", "type": "address"},
        {
          "internalType": "uint256",
          "name": "processCountIndex",
          "type": "uint256"
        },
        {"internalType": "uint16", "name": "namespace", "type": "uint16"}
      ],
      "name": "getProcessId",
      "outputs": [
        {"internalType": "bytes32", "name": "", "type": "bytes32"}
      ],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"}
      ],
      "name": "getResults",
      "outputs": [
        {"internalType": "string", "name": "", "type": "string"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"}
      ],
      "name": "incrementQuestionIndex",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "namespaceAddress",
      "outputs": [
        {"internalType": "address", "name": "", "type": "address"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint8[2]",
          "name": "mode_envelopeType",
          "type": "uint8[2]"
        },
        {
          "internalType": "string[3]",
          "name": "metadata_merkleRoot_merkleTree",
          "type": "string[3]"
        },
        {"internalType": "uint64", "name": "startBlock", "type": "uint64"},
        {"internalType": "uint32", "name": "blockCount", "type": "uint32"},
        {
          "internalType": "uint8[4]",
          "name": "questionCount_maxCount_maxValue_maxVoteOverwrites",
          "type": "uint8[4]"
        },
        {"internalType": "bool", "name": "uniqueValues", "type": "bool"},
        {
          "internalType": "uint16[2]",
          "name": "maxTotalCost_costExponent",
          "type": "uint16[2]"
        },
        {"internalType": "uint16", "name": "namespace", "type": "uint16"},
        {
          "internalType": "bytes32",
          "name": "paramsSignature",
          "type": "bytes32"
        }
      ],
      "name": "newProcess",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "predecessorAddress",
      "outputs": [
        {"internalType": "address", "name": "", "type": "address"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"},
        {
          "internalType": "string",
          "name": "censusMerkleRoot",
          "type": "string"
        },
        {"internalType": "string", "name": "censusMerkleTree", "type": "string"}
      ],
      "name": "setCensus",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "namespace", "type": "address"}
      ],
      "name": "setNamespaceAddress",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"},
        {"internalType": "string", "name": "results", "type": "string"}
      ],
      "name": "setResults",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "bytes32", "name": "processId", "type": "bytes32"},
        {
          "internalType": "enum IProcessStore.Status",
          "name": "newStatus",
          "type": "uint8"
        }
      ],
      "name": "setStatus",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "successorAddress",
      "outputs": [
        {"internalType": "address", "name": "", "type": "address"}
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ],
  "bytecode":
      "0x60806040523480156200001157600080fd5b5060405162002f7d38038062002f7d833981016040819052620000349162000169565b6001600160a01b03821615620000ac576001600160a01b038216301415620000795760405162461bcd60e51b8152600401620000709062000209565b60405180910390fd5b6200008d826001600160e01b036200014016565b620000ac5760405162461bcd60e51b81526004016200007090620001d2565b620000c0816001600160e01b036200014016565b620000df5760405162461bcd60e51b81526004016200007090620001a7565b600080546001600160a01b03199081163317909155600480546001600160a01b03848116919093161790558216156200013357600180546001600160a01b0319166001600160a01b03841617905562000138565b436003555b50506200024b565b6000806001600160a01b0383166200015d57600091505062000164565b5050803b15155b919050565b600080604083850312156200017c578182fd5b8251620001898162000232565b60208401519092506200019c8162000232565b809150509250929050565b602080825260119082015270496e76616c6964206e616d65737061636560781b604082015260600190565b60208082526013908201527f496e76616c6964207072656465636573736f7200000000000000000000000000604082015260600190565b6020808252600f908201526e21b0b713ba1031329034ba39b2b63360891b604082015260600190565b6001600160a01b03811681146200024857600080fd5b50565b612d22806200025b6000396000f3fe608060405234801561001057600080fd5b50600436106101215760003560e01c806346475c4c116100ad5780638de654ba116100715780638de654ba1461022b5780638eaa6ac01461023e578063aa7f172e14610266578063e07a51aa14610279578063f2bcb15e1461028c57610121565b806346475c4c146101ca57806374da4adb146101ea57806377882df4146101fd57806380faa3d21461021057806381c0de751461021857610121565b80631f496623116100f45780631f49662314610169578063305097bb14610189578063317daac51461019c57806334a2cdbc146101af57806343327872146101b757610121565b806308ffce24146101265780630f15f4c0146101445780631795010d1461014e5780631d88c05b14610161575b600080fd5b61012e61029f565b60405161013b91906124cb565b60405180910390f35b61014c6102ae565b005b61014c61015c3660046122fe565b61033f565b61012e610593565b61017c610177366004611fa5565b6105a2565b60405161013b919061258d565b61017c610197366004611fdd565b6105c5565b61017c6101aa366004612266565b6105fb565b61012e6106e9565b61012e6101c5366004612266565b6106f8565b6101dd6101d8366004612266565b6107cb565b60405161013b91906125ee565b61014c6101f8366004612266565b610940565b61014c61020b366004611f6d565b610b62565b61017c610c07565b61014c610226366004611f6d565b610c0d565b61014c610239366004612296565b610d75565b61025161024c366004612266565b610fbf565b60405161013b999897969594939291906124df565b61014c610274366004612135565b6113b0565b61014c6102873660046122ba565b61183b565b61017c61029a366004611f6d565b611a41565b6001546001600160a01b031681565b6001546001600160a01b031633146102e15760405162461bcd60e51b81526004016102d89061267e565b60405180910390fd5b600354156103015760405162461bcd60e51b81526004016102d8906129a8565b4360038190556040517f3ec796be1be7d03bff3a62b9fa594a60e947c1809bced06d929f145308ae57ce916103359161258d565b60405180910390a1565b600060035411801561035a57506002546001600160a01b0316155b6103765760405162461bcd60e51b81526004016102d890612927565b60008251116103975760405162461bcd60e51b81526004016102d89061262c565b60008151116103b85760405162461bcd60e51b81526004016102d890612748565b6000838152600660205260409020546201000090046001600160a01b031661041a576001546001600160a01b03166104025760405162461bcd60e51b81526004016102d8906126cf565b60405162461bcd60e51b81526004016102d8906129d0565b6000838152600660205260409020546201000090046001600160a01b031633146104565760405162461bcd60e51b81526004016102d890612770565b60008381526006602052604081206005015460ff16600481111561047657fe5b14806104a15750600360008481526006602052604090206005015460ff16600481111561049f57fe5b145b6104bd5760405162461bcd60e51b81526004016102d890612881565b6000838152600660205260409020546004166104eb5760405162461bcd60e51b81526004016102d890612a07565b6000838152600660209081526040909120835161051092600390920191850190611b3a565b506000838152600660209081526040909120825161053692600490920191840190611b3a565b50600083815260066020526040908190206005015490517fe54b983ab80f8982da0bb83c59ca327de698b5d0780451eba9706b4ffe06921191610586918691600160581b900461ffff1690612596565b60405180910390a1505050565b6002546001600160a01b031681565b6000806105ae84611a41565b90506105bb8482856105c5565b9150505b92915050565b60008383836040516020016105dc93929190612494565b6040516020818303038152906040528051906020012090509392505050565b6000818152600660205260408120546201000090046001600160a01b03166106cf576001546001600160a01b03166106455760405162461bcd60e51b81526004016102d8906126cf565b60015460405163317daac560e01b81526001600160a01b0390911690819063317daac59061067790869060040161258d565b60206040518083038186803b15801561068f57600080fd5b505afa1580156106a3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906106c7919061227e565b9150506106e4565b50600081815260066020819052604090912001545b919050565b6004546001600160a01b031681565b6000818152600660205260408120546201000090046001600160a01b03166107c4576001546001600160a01b03166107425760405162461bcd60e51b81526004016102d8906126cf565b6001546040516321993c3960e11b81526001600160a01b0390911690819063433278729061077490869060040161258d565b60206040518083038186803b15801561078c57600080fd5b505afa1580156107a0573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906106c79190611f89565b5030919050565b6000818152600660205260409020546060906201000090046001600160a01b031661089e576001546001600160a01b03166108185760405162461bcd60e51b81526004016102d8906126cf565b600154604051631191d71360e21b81526001600160a01b039091169081906346475c4c9061084a90869060040161258d565b60006040518083038186803b15801561086257600080fd5b505afa158015610876573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526106c79190810190612367565b60008281526006602090815260409182902060070180548351601f6002600019610100600186161502019093169290920491820184900484028101840190945280845290918301828280156109345780601f1061090957610100808354040283529160200191610934565b820191906000526020600020905b81548152906001019060200180831161091757829003601f168201915b50505050509050919050565b6000818152600660205260409020546201000090046001600160a01b031661098a576001546001600160a01b03166104025760405162461bcd60e51b81526004016102d8906126cf565b6000818152600660205260409020546201000090046001600160a01b031633146109c65760405162461bcd60e51b81526004016102d890612770565b60008181526006602052604081206005015460ff1660048111156109e657fe5b14610a035760405162461bcd60e51b81526004016102d890612a72565b6000818152600660205260409020546101009004600116610a365760405162461bcd60e51b81526004016102d8906126f2565b600081815260066020526040812060050154610a5b90610100900460ff166001611ae5565b60008381526006602052604090206005015490915060ff6201000090910481169082161015610af55760008281526006602052604090819020600501805461ff00191661010060ff851602179081905590517f2e4d6a3a868975a1e47c2ddc05451ebdececff07e59871dbc6cbaf9364aa06c691610ae8918591600160581b900461ffff169085906125d1565b60405180910390a1610b5e565b600082815260066020526040908190206005018054600160ff1990911681179182905591517fe64955704069c81c54f3fcca4da180a400f40da1bac10b68a9b42c753aa7a7f892610b55928692600160581b90910461ffff1691906125a8565b60405180910390a15b5050565b6000546001600160a01b03163314610b8c5760405162461bcd60e51b81526004016102d8906126a4565b610b9581611b17565b610bb15760405162461bcd60e51b81526004016102d890612601565b600480546001600160a01b0319166001600160a01b0383161790556040517f215ba443e028811c105c1bb484176ce9d9eec24ea7fb85c67a6bff78a04302b390610bfc9083906124cb565b60405180910390a150565b60035481565b6000546001600160a01b03163314610c375760405162461bcd60e51b81526004016102d8906126a4565b600060035411610c595760405162461bcd60e51b81526004016102d890612b35565b6002546001600160a01b031615610c825760405162461bcd60e51b81526004016102d89061271e565b6001600160a01b038116301415610cab5760405162461bcd60e51b81526004016102d89061280f565b610cb481611b17565b610cd05760405162461bcd60e51b81526004016102d890612949565b6000819050806001600160a01b0316630f15f4c06040518163ffffffff1660e01b8152600401600060405180830381600087803b158015610d1057600080fd5b505af1158015610d24573d6000803e3d6000fd5b5050600280546001600160a01b0319166001600160a01b03861617905550506040517f1f8bdb9825a71b7560200e2279fd4b503ac6814e369318e761928502882ee11a90610b559043908590612bcb565b6003816004811115610d8357fe5b60ff161115610da45760405162461bcd60e51b81526004016102d890612b81565b6000828152600660205260409020546201000090046001600160a01b0316610dee576001546001600160a01b03166104025760405162461bcd60e51b81526004016102d8906126cf565b6000828152600660205260409020546201000090046001600160a01b03163314610e2a5760405162461bcd60e51b81526004016102d890612770565b60008281526006602052604081206005015460ff1690816004811115610e4c57fe5b14158015610e6657506003816004811115610e6357fe5b14155b15610e835760405162461bcd60e51b81526004016102d890612881565b6003816004811115610e9157fe5b1415610edd57600083815260066020526040902054600216610ed8576000826004811115610ebb57fe5b14610ed85760405162461bcd60e51b81526004016102d8906127bd565b610f0b565b600083815260066020526040902054600216610f0b5760405162461bcd60e51b81526004016102d8906127bd565b806004811115610f1757fe5b826004811115610f2357fe5b1415610f415760405162461bcd60e51b81526004016102d890612a9d565b6000838152600660205260409020600501805483919060ff19166001836004811115610f6957fe5b0217905550600083815260066020526040908190206005015490517fe64955704069c81c54f3fcca4da180a400f40da1bac10b68a9b42c753aa7a7f891610586918691600160581b900461ffff169086906125a8565b610fc7611bb8565b6000610fd1611bd6565b6000806000610fde611bfd565b6000610fe8611c1b565b60008a8152600660205260409020546201000090046001600160a01b03166110d0576001546001600160a01b03166110325760405162461bcd60e51b81526004016102d8906126cf565b60015460405163023aa9ab60e61b81526001600160a01b03909116908190638eaa6ac090611064908e9060040161258d565b60006040518083038186803b15801561107c57600080fd5b505afa158015611090573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526110b8919081019061201e565b995099509950995099509950995099509950506113a3565b60008a81526006602090815260409182902082518084018452815460ff80821683526101008083049091168386015285516002808601805460018116159094026000190190931604601f81018790049096028101608090810190975260608101868152939f50620100009092046001600160a01b03169d50929490938493918401828280156111a05780601f10611175576101008083540402835291602001916111a0565b820191906000526020600020905b81548152906001019060200180831161118357829003601f168201915b505050918352505060038301805460408051602060026001851615610100026000190190941693909304601f81018490048402820184019092528181529382019392918301828280156112345780601f1061120957610100808354040283529160200191611234565b820191906000526020600020905b81548152906001019060200180831161121757829003601f168201915b505050918352505060048301805460408051602060026001851615610100026000190190941693909304601f81018490048402820184019092528181529382019392918301828280156112c85780601f1061129d576101008083540402835291602001916112c8565b820191906000526020600020905b8154815290600101906020018083116112ab57829003601f168201915b505050919092525050815460018301546005909301546040805160a08101825260ff610100840481168252620100008404811660208084019190915263010000008504821683850152640100000000850482166060808501919091526501000000000086048316608085015284519081018552600160381b860461ffff9081168252600160481b8704811692820192909252600160581b860490911693810193909352949c50600160b01b9093046001600160401b03169a5063ffffffff909416985082811697509095506601000000000000900416925090505b9193959799909294969850565b60006003541180156113cb57506002546001600160a01b0316155b6113e75760405162461bcd60e51b81526004016102d890612927565b8851600181161561141b576000886001600160401b03161161141b5760405162461bcd60e51b81526004016102d890612a31565b600281166114495760008763ffffffff16116114495760405162461bcd60e51b81526004016102d8906128f2565b8851516114685760405162461bcd60e51b81526004016102d890612798565b60208901515161148a5760405162461bcd60e51b81526004016102d8906127e8565b6040890151516114ac5760405162461bcd60e51b81526004016102d890612ac2565b855160ff166114cd5760405162461bcd60e51b81526004016102d890612654565b602086015160ff16158015906114ee57506064866001602002015160ff1611155b61150a5760405162461bcd60e51b81526004016102d890612b0b565b604086015160ff1661152e5760405162461bcd60e51b81526004016102d89061285c565b600881161561155b57606086015160ff1661155b5760405162461bcd60e51b81526004016102d8906128ad565b600061156633611a41565b3360009081526005602052604081208054600181018083559394509192909190811061158e57fe5b60009182526020909120018281559050600360018416156115ad575060005b60006115ba3385896105c5565b60008181526006602052604081209192508f906020020151815460ff191660ff9091161781558e60016020020151815461ff00191661010060ff909216919091021762010000600160b01b0319163362010000021767ffffffffffffffff60b01b1916600160b01b6001600160401b038f160217815560018101805463ffffffff191663ffffffff8e161790558d60006020020151816002019080519060200190611666929190611b3a565b506020808f0151805161167f9260038501920190611b3a565b5060408e0151805161169b916004840191602090910190611b3a565b5060058101805484919060ff191660018360048111156116b757fe5b02179055508a6000602002015160058201805460ff909216620100000262ff0000199092169190911790558a6001602002015160058201805460ff90921663010000000263ff000000199092169190911790558a6002602002015160058201805460ff9092166401000000000264ff00000000199092169190911790558a6003602002015160058201805465ff000000000019166501000000000060ff909316929092029190911766ff000000000000191666010000000000008c151502179055886000602002015160058201805461ffff909216600160381b0268ffff000000000000001990921691909117905588600160200201516005820180546affff0000000000000000001916600160481b61ffff938416021761ffff60581b1916600160581b928b1692909202919091179055600681018790556040517f2399440b5a42cbc7ba215c9c176f7cd16b511a8727c1f277635f3fce4649156e906118229084908b90612596565b60405180910390a1505050505050505050505050505050565b600081511161185c5760405162461bcd60e51b81526004016102d890612838565b6000828152600660205260409020546201000090046001600160a01b03166118a6576001546001600160a01b03166104025760405162461bcd60e51b81526004016102d8906126cf565b600480546000848152600660205260409081902060050154905163db246f2160e01b81526001600160a01b0390921692839263db246f21926118f792600160581b90910461ffff1691339101612bae565b60206040518083038186803b15801561190f57600080fd5b505afa158015611923573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611947919061224a565b6119635760405162461bcd60e51b81526004016102d890612b5d565b600260008481526006602052604090206005015460ff16600481111561198557fe5b141580156119b35750600460008481526006602052604090206005015460ff1660048111156119b057fe5b14155b6119cf5760405162461bcd60e51b81526004016102d890612971565b600083815260066020908152604090912083516119f492600790920191850190611b3a565b5060008381526006602052604090819020600501805460ff19166004179055517f5aff397e0d9bfad4e73dfd9c2da1d146ce7fe8cfd1a795dbf6b95b417236fa4c9061058690859061258d565b6001600160a01b038116600090815260056020526040812054611aa8576001546001600160a01b0316611a76575060006106e4565b60015460405163795e58af60e11b81526001600160a01b0390911690819063f2bcb15e906106779086906004016124cb565b6001600160a01b038216600090815260056020526040902080546000198101908110611ad057fe5b60009182526020909120015460010192915050565b600082820160ff8085169082161015611b105760405162461bcd60e51b81526004016102d890612ae9565b9392505050565b6000806001600160a01b038316611b325760009150506106e4565b50503b151590565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f10611b7b57805160ff1916838001178555611ba8565b82800160010185558215611ba8579182015b82811115611ba8578251825591602001919060010190611b8d565b50611bb4929150611c39565b5090565b60405180604001604052806002906020820280368337509192915050565b60405180606001604052806003905b6060815260200190600190039081611be55790505090565b6040518060a001604052806005906020820280368337509192915050565b60405180606001604052806003906020820280368337509192915050565b611c5391905b80821115611bb45760008155600101611c3f565b90565b80516105bf81612c73565b600082601f830112611c71578081fd5b611c7b6060612be2565b9050808260005b6003811015611cad57611c988683358701611e8b565b83526020928301929190910190600101611c82565b50505092915050565b600082601f830112611cc6578081fd5b611cd06060612be2565b9050808260005b6003811015611cad57611ced8683518701611ede565b83526020928301929190910190600101611cd7565b600082601f830112611d12578081fd5b611d1c6040612be2565b9050808284604085011115611d3057600080fd5b60005b6002811015611cad578135611d4781612ca6565b83526020928301929190910190600101611d33565b600082601f830112611d6c578081fd5b611d766060612be2565b9050808284606085011115611d8a57600080fd5b60005b6003811015611cad578151611da181612ca6565b83526020928301929190910190600101611d8d565b600082601f830112611dc6578081fd5b611dd06080612be2565b9050808284608085011115611de457600080fd5b60005b6004811015611cad578135611dfb81612cdd565b83526020928301929190910190600101611de7565b600082601f830112611e20578081fd5b611e2a60a0612be2565b905080828460a085011115611e3e57600080fd5b60005b6005811015611cad578151611e5581612cdd565b83526020928301929190910190600101611e41565b80356105bf81612c8b565b80516105bf81612c8b565b80516105bf81612c99565b600082601f830112611e9b578081fd5b8135611eae611ea982612c24565b612be2565b9150808252836020828501011115611ec557600080fd5b8060208401602084013760009082016020015292915050565b600082601f830112611eee578081fd5b8151611efc611ea982612c24565b9150808252836020828501011115611f1357600080fd5b611f24816020840160208601612c47565b5092915050565b80356105bf81612ca6565b80356105bf81612cb6565b80516105bf81612cb6565b80356105bf81612cc8565b80516105bf81612cc8565b80356105bf81612cdd565b600060208284031215611f7e578081fd5b8135611b1081612c73565b600060208284031215611f9a578081fd5b8151611b1081612c73565b60008060408385031215611fb7578081fd5b8235611fc281612c73565b91506020830135611fd281612ca6565b809150509250929050565b600080600060608486031215611ff1578081fd5b8335611ffc81612c73565b925060208401359150604084013561201381612ca6565b809150509250925092565b60008060008060008060008060006102008a8c03121561203c578687fd5b8a601f8b011261204a578687fd5b6120546040612be2565b808b60408d018e811115612066578a8bfd5b8a5b600281101561209157825161207c81612cdd565b85526020948501949290920191600101612068565b50829c5061209f8f82611c56565b9b505050505060608a01516001600160401b038111156120bd578788fd5b6120c98c828d01611cb6565b9750506120d98b60808c01611f57565b95506120e88b60a08c01611f41565b94506120f78b60c08c01611e80565b93506121068b60e08c01611e10565b92506121168b6101808c01611e75565b91506121268b6101a08c01611d5c565b90509295985092959850929598565b60008060008060008060008060006101c08a8c031215612153578283fd5b8a601f8b0112612161578283fd5b61216e611ea96002612c08565b808b8d60408e01111561217f578586fd5b855b60028110156121a9576121948f83611f62565b84526020938401939190910190600101612181565b50909a5050506001600160401b0360408b013511156121c6578283fd5b6121d68b60408c01358c01611c61565b97506121e58b60608c01611f4c565b96506121f48b60808c01611f36565b95506122038b60a08c01611db6565b94506122138b6101208c01611e6a565b93506122238b6101408c01611d02565b92506122338b6101808c01611f2b565b91506101a08a013590509295985092959850929598565b60006020828403121561225b578081fd5b8151611b1081612c8b565b600060208284031215612277578081fd5b5035919050565b60006020828403121561228f578081fd5b5051919050565b600080604083850312156122a8578182fd5b823591506020830135611fd281612c99565b600080604083850312156122cc578182fd5b8235915060208301356001600160401b038111156122e8578182fd5b6122f485828601611e8b565b9150509250929050565b600080600060608486031215612312578081fd5b8335925060208401356001600160401b038082111561232f578283fd5b61233b87838801611e8b565b93506040860135915080821115612350578283fd5b5061235d86828701611e8b565b9150509250925092565b600060208284031215612378578081fd5b81516001600160401b0381111561238d578182fd5b6105bb84828501611ede565b6001600160a01b03169052565b6000826060810183835b60038110156123df5783830387526123c9838351612451565b60209788019790935091909101906001016123b0565b509095945050505050565b8060005b600381101561241157815161ffff168452602093840193909101906001016123ee565b50505050565b8060005b600581101561241157815160ff1684526020938401939091019060010161241b565b15159052565b6005811061244d57fe5b9052565b60008151808452612469816020860160208601612c47565b601f01601f19169290920160200192915050565b63ffffffff169052565b6001600160401b03169052565b60609390931b6bffffffffffffffffffffffff19168352601483019190915260f01b6001600160f01b031916603482015260360190565b6001600160a01b0391909116815260200190565b6000610200828c835b600281101561250a57815160ff168352602092830192909101906001016124e8565b50505061251a604084018c612399565b80606084015261252c8184018b6123a6565b91505061253c6080830189612487565b61254960a083018861247d565b61255660c0830187612443565b61256360e0830186612417565b61257161018083018561243d565b61257f6101a08301846123ea565b9a9950505050505050505050565b90815260200190565b91825261ffff16602082015260400190565b83815261ffff8316602082015260608101600583106125c357fe5b826040830152949350505050565b92835261ffff91909116602083015260ff16604082015260600190565b600060208252611b106020830184612451565b602080825260119082015270496e76616c6964206e616d65737061636560781b604082015260600190565b6020808252600e908201526d139bc813595c9adb1948149bdbdd60921b604082015260600190565b60208082526010908201526f139bc81c5d595cdd1a5bdb90dbdd5b9d60821b604082015260600190565b6020808252600c908201526b155b985d5d1a1bdc9a5e995960a21b604082015260600190565b60208082526011908201527037b7363ca1b7b73a3930b1ba27bbb732b960791b604082015260600190565b602080825260099082015268139bdd08199bdd5b9960ba1b604082015260600190565b602080825260129082015271141c9bd8d95cdcc81b9bdd081cd95c9a585b60721b604082015260600190565b60208082526010908201526f416c726561647920696e61637469766560801b604082015260600190565b6020808252600e908201526d4e6f204d65726b6c65205472656560901b604082015260600190565b6020808252600e908201526d496e76616c696420656e7469747960901b604082015260600190565b6020808252600b908201526a4e6f206d6574616461746160a81b604082015260600190565b6020808252601190820152704e6f7420696e7465727275707469626c6560781b604082015260600190565b6020808252600d908201526c139bc81b595c9adb19549bdbdd609a1b604082015260600190565b6020808252600f908201526e21b0b713ba1031329034ba39b2b63360891b604082015260600190565b6020808252600a90820152694e6f20726573756c747360b01b604082015260600190565b6020808252600b908201526a4e6f206d617856616c756560a81b604082015260600190565b602080825260129082015271141c9bd8d95cdcc81d195c9b5a5b985d195960721b604082015260600190565b60208082526025908201527f4f7665727772697465206e65656473206d6178566f74654f7665727772697465604082015264073203e20360dc1b606082015260800190565b6020808252818101527f556e696e7465727275707469626c65206e6565647320626c6f636b436f756e74604082015260600190565b602080825260089082015267496e61637469766560c01b604082015260600190565b6020808252600e908201526d139bdd08184818dbdb9d1c9858dd60921b604082015260600190565b60208082526017908201527f43616e63656c6564206f7220616c726561647920736574000000000000000000604082015260600190565b6020808252600e908201526d416c72656164792061637469766560901b604082015260600190565b6020808252601d908201527f4e6f7420666f756e643a20547279206f6e207072656465636573736f72000000604082015260600190565b60208082526010908201526f526561642d6f6e6c792063656e73757360801b604082015260600190565b60208082526021908201527f4175746f207374617274207265717569726573206120737461727420626c6f636040820152606b60f81b606082015260800190565b60208082526011908201527050726f63657373206e6f7420726561647960781b604082015260600190565b6020808252600b908201526a26bab9ba103234b33332b960a91b604082015260600190565b6020808252600d908201526c4e6f206d65726b6c655472656560981b604082015260600190565b6020808252600890820152676f766572666c6f7760c01b604082015260600190565b60208082526010908201526f125b9d985b1a59081b585e10dbdd5b9d60821b604082015260600190565b6020808252600e908201526d4d7573742062652061637469766560901b604082015260600190565b6020808252600a90820152694e6f74206f7261636c6560b01b604082015260600190565b602080825260139082015272496e76616c69642073746174757320636f646560681b604082015260600190565b61ffff9290921682526001600160a01b0316602082015260400190565b9182526001600160a01b0316602082015260400190565b6040518181016001600160401b0381118282101715612c0057600080fd5b604052919050565b60006001600160401b03821115612c1d578081fd5b5060200290565b60006001600160401b03821115612c39578081fd5b50601f01601f191660200190565b60005b83811015612c62578181015183820152602001612c4a565b838111156124115750506000910152565b6001600160a01b0381168114612c8857600080fd5b50565b8015158114612c8857600080fd5b60058110612c8857600080fd5b61ffff81168114612c8857600080fd5b63ffffffff81168114612c8857600080fd5b6001600160401b0381168114612c8857600080fd5b60ff81168114612c8857600080fdfea26469706673582212207770fe9ec2027505a6516e73cbf332a9c3b39795f96a3661e6dff6d7418ca43164736f6c634300060a0033"
};

final List<Map<String, Object>> processAbi = _rawContractData['abi'];

final String processBytecode = _rawContractData['bytecode'];