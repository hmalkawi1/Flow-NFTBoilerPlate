import NonFungibleToken from 0x01cf0e2f2f715450

pub contract FlightManagement: NonFungibleToken {
    pub var totalSupply: UInt64

    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    // The only thing we added here is:
    // `: NonFungibleToken.INFT`
    pub resource NFT: NonFungibleToken.INFT {
    pub let id: UInt64

    pub let name: String
    pub let favouriteFood: String
    pub let luckyNumber: Int

    init(_name: String, _favouriteFood: String, _luckyNumber: Int) {
      self.id = self.uuid

      self.name = _name
      self.favouriteFood = _favouriteFood
      self.luckyNumber = _luckyNumber
    }
  }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // Notice that the return type is now `@NonFungibleToken.NFT`, 
        // NOT just `@NFT`
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
        let nft <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("This NFT does not exist in this Collection.")
        
        emit Withdraw(id: nft.id, from: self.owner?.address)

        return <- nft
        }

        // Notice that the `token` parameter type is now 
        // `@NonFungibleToken.NFT`, NOT just `@NFT`
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            emit Deposit(id: nft.id, to: self.owner?.address)

            self.ownedNFTs[nft.id] <-! nft
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowAuthNFT(id: UInt64): &NFT {
            let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return ref as! &NFT
            
        }   


        init() {
        self.ownedNFTs <- {}
        }

        destroy() {
        destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub resource Minter {

    pub fun createNFT(name: String, favouriteFood: String, luckyNumber: Int): @NFT {
      return <- create NFT(_name: name, _favouriteFood: favouriteFood, _luckyNumber: luckyNumber)
    }

    pub fun createMinter(): @Minter {
      return <- create Minter()
    }

  }

    init(){
        self.totalSupply = 0
        emit ContractInitialized()
        self.account.save(<- create Minter(), to: /storage/Minter)

    }
}
 