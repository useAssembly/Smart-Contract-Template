# Smart Contract Example Projects - Hardhat

### MudCats Smart Contract Example

```ts
npx hardhat run scripts/MudCats/deploy.ts --network goerli

npx hardhat verify \
--contract "contracts/MudCats/MudCats.sol:MudCats" \
--network goerli 0xe2d9935cbcf5f8dc003e2020ddb5a525cf005207
```

### Nakedz Smart Contract Example

```ts
npx hardhat run scripts/Nakedz/deploy.ts --network goerli

npx hardhat verify \
--contract "contracts/Nakedz/Nakedz.sol:Nakedz" \
--network goerli 0x943ccC0c62FcE3e1B5357458C38bB568408885Ec
```

### Airfoil Token Smart Contract Example

```ts
npx hardhat run scripts/AirfoilToken/deploy.ts --network goerli

npx hardhat verify \
--contract "contracts/AirfoilToken/AirfoilToken.sol:AirfoilToken" \
--network goerli 0xa91feE4AAd579697d447ABdf34B48Ba151E9d03d
```

### Hardhat Commands

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
```

### Common Errors

```shell
An unexpected error occurred:
[Error: ENOENT: no such file or directory, open '.../hardhat-contract-examples/artifacts/build-info/e58f67f4a05685e71e20c4fc6ac3e9e7.json'] {
  errno: -2,
  code: 'ENOENT',
  syscall: 'open',
  path: '.../hardhat-contract-examples/artifacts/build-info/e58f67f4a05685e71e20c4fc6ac3e9e7.json'
}
```

Solution : `npx hardhat clean`
