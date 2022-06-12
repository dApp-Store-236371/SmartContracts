import { Contract } from "ethers";

const DAppStore = artifacts.require("dAppstore");

Contract('DAppStore', () => {
    it('first test', () => {
            const dAppStore = DAppStore.deployed();
            console.log(dAppStore.address);
            assert.isTrue(dAppStore.address !== undefined);
        }
    )
    it('second test', async () => {
        const dAppStore = await DAppStore.deployed();
        console.log(dAppStore.address);
        assert.isTrue(dAppStore.address === undefined);
    }
)
});