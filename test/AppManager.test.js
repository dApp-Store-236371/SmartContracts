
const sha3 = require('js-sha3').keccak_256;
const keccak256 = require('keccak256')
var chai = require("chai");
const expect = chai.expect;
const assert = chai.assert;
let catchRevert = require("./exceptions.js").catchRevert;


const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');




const _AppManager = artifacts.require("AppManager");

function expectAppInfo(app, id, price = 8, owned=true){
    expect(app.id).to.equal(id.toString());
    expect(app.name).to.equal(`name${id}`);
    expect(app.description).to.equal(`description${id}`);
    if (owned){
        expect(app.magnetLink).to.equal(`link${id}`);
    }
    else{
        expect(app.magnetLink).to.equal('');
    }
    expect(app.imgUrl).to.equal(`img${id}`);
    expect(app.category).to.equal(`category${id}`);
    expect(app.company).to.equal(`company${id}`);
    expect(app.price).to.equal(price.toString());
    expect(app.category).to.equal(`category${id}`);
    expect(app.fileSha256).to.equal(`fileSha${id}`);
    return true;
}

function compareApps(app1, app2){
    // console.log(`
    //     app1.id: ${app1.id} app2.id: ${app2.id} app1.id == app2.id: ${app1.id == app2.id}
    //     app1.name: ${app1.name} app2.name: ${app2.name} app1.name == app2.name: ${app1.name == app2.name}
    //     app1.description: ${app1.description} app2.description: ${app2.description} app1.description == app2.description: ${app1.description == app2.description}
    //     app1.magnetLink: ${app1.magnetLink} app2.magnetLink: ${app2.magnetLink} app1.magnetLink == app2.magnetLink: ${app1.magnetLink == app2.magnetLink}
    //     app1.imgUrl: ${app1.imgUrl} app2.imgUrl: ${app2.imgUrl} app1.imgUrl == app2.imgUrl: ${app1.imgUrl == app2.imgUrl}
    //     app1.company: ${app1.company} app2.company: ${app2.company} app1.company == app2.company: ${app1.company == app2.company}
    //     app1.price: ${app1.price} app2.price: ${app2.price} app1.price == app2.price: ${app1.price == app2.price}
    //     app1.category: ${app1.category} app2.category: ${app2.category} app1.category == app2.category: ${app1.category == app2.category}
    //     app1.fileSha256: ${app1.fileSha256} app2.fileSha256: ${app2.fileSha256} app1.fileSha256 == app2.fileSha256: ${app1.fileSha256 == app2.fileSha256}
    // `);
    expect(app1.id).to.equal(app2.id);
    // console.log(`app1.id: ${app1.id} app2.id: ${app2.id} app1.id == app2.id: ${app1.id == app2.id}`);
    expect(app1.name).to.equal(app2.name);
    // console.log(`app1.name: ${app1.name} app2.name: ${app2.name} app1.name == app2.name: ${app1.name == app2.name}`);
    expect(app1.description).to.equal(app2.description);
    // console.log(`app1.description: ${app1.description} app2.description: ${app2.description} app1.description == app2.description: ${app1.description == app2.description}`);
    expect(app1.magnetLink).to.equal(app2.magnetLink);
    // console.log(`app1.magnetLink: ${app1.magnetLink} app2.magnetLink: ${app2.magnetLink} app1.magnetLink == app2.magnetLink: ${app1.magnetLink == app2.magnetLink}`);
    expect(app1.imgUrl).to.equal(app2.imgUrl);
    // console.log(`app1.imgUrl: ${app1.imgUrl} app2.imgUrl: ${app2.imgUrl} app1.imgUrl == app2.imgUrl: ${app1.imgUrl == app2.imgUrl}`);
    expect(app1.company).to.equal(app2.company);
    // console.log(`app1.company: ${app1.company} app2.company: ${app2.company} app1.company == app2.company: ${app1.company == app2.company}`);
    expect(app1.price).to.equal(app2.price);
    // console.log(`app1.price: ${app1.price} app2.price: ${app2.price} app1.price == app2.price: ${app1.price == app2.price}`);
    expect(app1.category).to.equal(app2.category);
    // console.log(`app1.category: ${app1.category} app2.category: ${app2.category} app1.category == app2.category: ${app1.category == app2.category}`);
    expect(app1.fileSha256).to.equal(app2.fileSha256);
    // console.log(`app1.fileSha256: ${app1.fileSha256} app2.fileSha256: ${app2.fileSha256} app1.fileSha256 == app2.fileSha256: ${app1.fileSha256 == app2.fileSha256}`);
    return true;
}

async function createXApps(appManager, x_apps, user_address){  
    for (let i = 0; i < x_apps; i++) {
    // console.log(`Creating app ${i}`);
    const idx = `${i}`;
    const name = "name" + idx;
    const description = "description" + idx;
    const link = "link" + idx;
    const img = "img" + idx;
    const company = "company" + idx;
    const price = 8;
    const category = "category" + idx;
    const fileSha = "fileSha" + idx;
    const app = await appManager.createNewApp(
    name,
    description,
    link,
    img,
    company,
    price,
    category,
    fileSha,
    { from: user_address }
    );}
}

function calcRating(ratingInt, ratingModulu, ratingNum){
    return parseInt(ratingNum) === 0? 0: (parseInt(ratingModulu) / parseInt(ratingNum)) + parseInt(ratingInt);
}

// Start test block
contract('AppManager', (accounts) => {
    
    const x_apps = 10;
    let user_uploaded_apps = {};
    const user_address = accounts[0];
    let appManager;
    
    it('should deploy the contract', async () => {
        appManager = await _AppManager.deployed();
        assert.isOk(appManager);
        expect(await appManager.getAppCount().then(
            (result) => {
                return result.toNumber();
            }
        )).to.equal(0);
    });


    it(`Create - add ${x_apps} apps for same user`, async () => {
        const initial_app_count =await appManager.getAppCount().then(res => res.toNumber());
        const user_address = accounts[0];

        await createXApps(appManager, x_apps, accounts[0]);
        console.log(`Created ${x_apps} apps for user ${user_address}`);
        console.log(`getAppCount(): ${await appManager.getAppCount().then(res => res.toNumber())}`);
        const apps_count = await appManager.getAppCount().then(res => res.toNumber());
        console.assert(apps_count == x_apps, "app count is not correct");
        assert.isTrue(apps_count == x_apps + initial_app_count, "app count is not correct");
        // user_uploaded_apps
        console.log('type of getAppBatch: ', typeof await appManager.getAppBatch);
        const apps = await appManager.getAppBatch(initial_app_count, x_apps);
        user_uploaded_apps = {...user_uploaded_apps, ...apps};
    });

    // it('createNewApp - Correct event output', async () => {
    //     const new_user = accounts[2];
    //     //create app
    //     const idx = AppManager.getAppCount().then(res => res.toNumber());
    //     const tx = await AppManager.createNewApp(
    //         "name" + idx,
    //         "description" + idx,
    //         "link" + idx,
    //         "img" + idx,
    //         "company" + idx,
    //         8,
    //         "category" + idx,
    //         "fileSha" + idx,
    //         { from: new_user }
    //     );
        
    //     // console.log('createNewApp - tx.receipt -->', tx.receipt);
    //     let event = tx.receipt.rawLogs.some(l => { 
    //         // console.log('topics -->', l.topics);
    //         // console.log('sha3("UserCreated(address payable, address)") -->', keccak256("UserCreated(address payable,address)"));
    //         // console.log('sha3("Events:UserCreated(address payable, address)") -->', keccak256("Events:UserCreated(address payable,address)"));
    //         // console.log('sha3("Events.UserCreated(address payable, address)") -->', keccak256("Events.UserCreated(address payable,address)"));
    //         // console.log('sha3("dAppstore:Events:UserCreated(address payable, address)") -->', keccak256("dAppstore:Events:UserCreated(address payable,address)"));
    //         // console.log('sha3("dAppstore.Events.UserCreated(address payable, address)") -->', keccak256("dAppstore.Events.UserCreated(address payable,address)"));

    //         for (let i = 0; i < l.topics.length; i++) {

    //             if (l.topics[0] == '0x' + sha3("UserCreated(address payable, address)") || l.topics[0] == '0x' + sha3("Events:UserCreated(address payable, address)")) {
    //                 console.log('event -->', topics[i]);
    //                 return true;
    //             }
    //         }
    //         console.log('found nothing');
    //         return false;
    //     });
    //     console.log('event -->', event);
    //     const allEvents = await AppManager.getPastEvents('allEvents',{ fromBlock:0, toBlock:'latest'});
    //     console.log('allEvents -->', allEvents);
        
    //     assert.ok(event, "event is not stored");
    //     // expectEvent(receipt, 'OwnershipTransferred');
    // });
    // it('purchaseApp - correct event output', async () => {
    //     const new_user = accounts[3];
    //     const appCount = await AppManager.getAppCount().then(res => res.toNumber());
    //     const rnd_idx = Math.floor(Math.random() * appCount);
    //     const receipt = await AppManager.purchaseApp(rnd_idx, { from: new_user, value: 8 });
    //     expectEvent(receipt, 'UserPurchasedApp');
    // });
    it('AppBatch - Should get first app', async () =>{
        const apps_count = await appManager.getAppCount().then(res => res.toNumber());
        expect(apps_count).to.be.greaterThan(0);
        const appOwned = await appManager.getAppBatch(0, 1).then(res => res[0]);
        assert.isDefined(appOwned, "app is not defined");
        assert.isTrue(expectAppInfo(appOwned, 0), "app info is not correct");

        const appNotOwned = await appManager.getAppBatch(0, 1).then(res => res[0]);
        assert.isDefined(appNotOwned, "app is not defined");
        assert.isTrue(expectAppInfo(appNotOwned, 0), "app info is not correct");
    });

    it('AppBatch - Should get last app', async () =>{
        console.log ('there are ', await appManager.getAppCount().then(res => res.toNumber()), ' apps');
        const app = await appManager.getAppBatch(await appManager.getAppCount() -1, 1).then(res => res[0]);
        assert.isDefined(app, "app is not defined");
        assert.isTrue(expectAppInfo(app, x_apps - 1), "app info is not correct");
    });

    it(`AppBatch - Should get ${Math.ceil(x_apps/5)} apps from index 0 to  ${Math.ceil(x_apps/5)}`, async () => {
        const apps_num = Math.ceil(x_apps/5);
        const appBatch = await appManager.getAppBatch(0, apps_num);
        assert.isDefined(appBatch, "appBatch is not defined");
        expect(appBatch.length).to.equal(apps_num);

        for (i = 0; i < apps_num; i++) {
            assert.isTrue(expectAppInfo(appBatch[i], i));
        }
    });

    it(`AppBatch - Should get ${Math.ceil(x_apps/5)} apps from random index`, async () => {
        const apps_num = Math.ceil(x_apps/5);
        const rnd_idx = Math.floor(Math.random() * x_apps);
        const appBatch = await appManager.getAppBatch(rnd_idx, apps_num);
        expect(appBatch.length).to.equal(apps_num);
        expect(parseInt(appBatch[0].id)).to.equal(rnd_idx);
        expect(parseInt(appBatch[apps_num-1].id)).to.equal((rnd_idx + apps_num - 1) % x_apps);
        for (i = 0; i < apps_num; i++) {
            expectAppInfo(appBatch[i], (i + rnd_idx) % x_apps);
        }
    });

    it('AppBatch - Get apps in cyclical order', async () => {
        const rndIdx = Math.floor(Math.random() * x_apps);
        // console.log('rndIdx -->', rndIdx);
        const apps_count = await appManager.getAppCount().then(res => res.toNumber());
        // const appBatch = await AppManager.getAppBatch(rndIdx, Math.floor(Math.random() * apps_count - 1) + 1);
        const appBatch = await appManager.getAppBatch(rndIdx,  apps_count);
        console.assert(appBatch.length == apps_count, "appBatch length is not correct");
        expect(appBatch.length).to.equal(apps_count);
        console.assert(parseInt(appBatch[0].id) == rndIdx, "appBatch first app is not correct");
        expect(parseInt(appBatch[0].id)).to.equal(rndIdx);
        console.assert(parseInt(appBatch[apps_count-1].id) == (rndIdx + apps_count - 1) % x_apps, "appBatch last app is not correct");
        expect(parseInt(appBatch[apps_count-1].id)).to.equal((rndIdx + apps_count - 1) % x_apps);
    });

    it('AppBatch - Get all apps when asking for more apps than appsCount', async () => {
        const rndIdx = Math.floor(Math.random() * x_apps);
        const apps_count = await appManager.getAppCount().then(res => res.toNumber());
        const appBatch = await appManager.getAppBatch(rndIdx, apps_count + Math.floor(Math.random() * 100) + 1);
        expect(appBatch.length).to.equal(apps_count);
        expect(parseInt(appBatch[0].id)).to.equal(rndIdx);
        expect(parseInt(appBatch[apps_count-1].id)).to.equal((rndIdx + apps_count - 1) % x_apps);
    });

    it('AppBatch - Fail to get app that doesn\'t exist', async () => {
        const apps_count = await appManager.getAppCount().then(res => res.toNumber());

        await catchRevert(appManager.getAppBatch(apps_count, 1, {from: accounts[0]}));
    });

    it("UpdateApp - update nothing", async () => {
        const original_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const updated  = await appManager.updateApp(
            0,
            '',
            '',
            '',
            '',
            0,
            '');
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        compareApps(original_app, updated_app);
    });
    
    it("UpdateApp - update name", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_name = "new_name" + app.id;
        const tx = await appManager.updateApp(
          app.id,
          new_name,
          '',
          '',
          '',
          0,
          '');
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.name).to.equal(new_name);
    });

    it("UpdateApp - update description", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_description = "new_description" + app.id;
        const tx = await appManager.updateApp(
            app.id,
            '',
            new_description,
            '',
            '',
            0,
            '');
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.description).to.equal(new_description);
    });

    it("UpdateApp - update imgUrl", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_url = "new_img" + app.id;
        const tx = await appManager.updateApp(
            app.id,
            '',
            '',
            '',
            new_url,
            0,
            '');
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.imgUrl).to.equal(new_url);
        expect(app.id).to.equal(updated_app.id);
        expect(app.name).to.equal(updated_app.name);
        expect(app.description).to.equal(updated_app.description);
        expect(app.magnetLink).to.equal(updated_app.magnetLink);
        expect(app.fileSha256).to.equal(updated_app.fileSha256);
        expect(app.price).to.equal(updated_app.price);
    });
      
    it("UpdateApp - update price", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_price = Math.floor(Math.random() * 100 + 1);
        const tx = await appManager.updateApp(
            app.id,
            '',
            '',
            '',
            '',
            new_price,
            '');
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.price).to.equal(new_price.toString());
    });

    it("UpdateApp - fail update just magnetLink", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_magnetLink = "new_magnetLink" + app.id;
        await catchRevert(appManager.updateApp(
            app.id,
            '',
            '',
            new_magnetLink,
            '',
            0,
            ''));
    });

    it("UpdateApp - fail update just fileSha256", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_fileSha256 = "new_fileSha256" + app.id;
        await catchRevert(appManager.updateApp(
            app.id,
            '',
            '',
            '',
            '',
            0,
            new_fileSha256));
    });

    it("UpdateApp - update new version", async () => {
        app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        const new_magnetLink = "new_magnetLink" + app.id;
        const new_fileSha256 = "new_fileSha256" + app.id;
        const tx = await appManager.updateApp(
            app.id,
            '',
            '',
            new_magnetLink,
            '',
            0,
            new_fileSha256);
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.magnetLink).to.equal(new_magnetLink);
        expect(updated_app.fileSha256).to.equal(new_fileSha256);
    });

    it("updates all  fields", async () => { 
        const app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        
        const new_fileSha = "filesha" + app.id;
        const new_name = "name" + app.id;
        const new_description = "description" + app.id;
        const new_img = "img" + app.id;
        const new_link = "link" + app.id;
        const new_price = 8;
        await appManager.updateApp(
            app.id,
            new_name,
            new_description,
            new_link,
            new_img,
            new_price,
            new_fileSha
        )
    
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.name).to.equal(new_name);
        expect(updated_app.description).to.equal(new_description);
        expect(updated_app.magnetLink).to.equal(new_link);
        expect(updated_app.imgUrl).to.equal(new_img);
        expect(updated_app.price).to.equal(new_price.toString());
        expect(updated_app.fileSha256).to.equal(new_fileSha);
    });

    it("rateApp - give app new rating and change it", async () => {
        const app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(calcRating(app.ratingInt, app.ratingModulu, app.numRatings)).to.equal(0);
        const new_rating = Math.floor(Math.random() * 5 + 1);
        const tx = await appManager.rateApp(app.id, new_rating, 0);
        const updated_app = await appManager.getAppBatch(0, 1).then(res => res[0]);
        expect(calcRating(updated_app.ratingInt, updated_app.ratingModulu, updated_app.numRatings)).to.equal(new_rating);
    });

});