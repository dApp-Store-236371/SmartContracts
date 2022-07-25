const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');
const sha3 = require('js-sha3').keccak_256;
const keccak256 = require('keccak256')
var chai = require("chai");
const expect = chai.expect;
const assert = chai.assert;

const DAppStore = artifacts.require("dAppstore");

// Start test block
contract('dAppStore', (accounts) => {
    const x_apps = 10;
    let user_uploaded_apps = {};
    const user_address = accounts[0];
    let dAppStore;
    const expectAppInfo = (app, id, price = 8) =>{
        expect(app.id).to.equal(id.toString());
        expect(app.name).to.equal(`name${id}`);
        expect(app.description).to.equal(`description${id}`);
        expect(app.magnetLink).to.equal(`link${id}`);
        expect(app.imgUrl).to.equal(`img${id}`);
        expect(app.company).to.equal(`company${id}`);
        expect(app.price).to.equal(price.toString());
        expect(app.category).to.equal(`category${id}`);
        expect(app.fileSha256).to.equal(`fileSha${id}`);
        return true;
    }
    const compareApps = (app1, app2) => {
        console.log(`
            app1.id: ${app1.id} app2.id: ${app2.id} app1.id == app2.id: ${app1.id == app2.id}
            app1.name: ${app1.name} app2.name: ${app2.name} app1.name == app2.name: ${app1.name == app2.name}
            app1.description: ${app1.description} app2.description: ${app2.description} app1.description == app2.description: ${app1.description == app2.description}
            app1.magnetLink: ${app1.magnetLink} app2.magnetLink: ${app2.magnetLink} app1.magnetLink == app2.magnetLink: ${app1.magnetLink == app2.magnetLink}
            app1.imgUrl: ${app1.imgUrl} app2.imgUrl: ${app2.imgUrl} app1.imgUrl == app2.imgUrl: ${app1.imgUrl == app2.imgUrl}
            app1.company: ${app1.company} app2.company: ${app2.company} app1.company == app2.company: ${app1.company == app2.company}
            app1.price: ${app1.price} app2.price: ${app2.price} app1.price == app2.price: ${app1.price == app2.price}
            app1.category: ${app1.category} app2.category: ${app2.category} app1.category == app2.category: ${app1.category == app2.category}
            app1.fileSha256: ${app1.fileSha256} app2.fileSha256: ${app2.fileSha256} app1.fileSha256 == app2.fileSha256: ${app1.fileSha256 == app2.fileSha256}
        `);
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
    const createXApps = async (x_apps, user_address) => {  
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
        const app = await dAppStore.createNewApp(
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

    //Test case
    it('Create - Should create a new dAppStore contract', async () => {
        dAppStore = await DAppStore.deployed();
        assert.isOk(dAppStore.address);
        const user_address = accounts[0];
    });

    it(`Create - add ${x_apps} apps for same user`, async () => {
        const initial_app_count =await dAppStore.getAppCount().then(res => res.toNumber());
        const user_address = accounts[0];

        await createXApps(x_apps, accounts[0]);
        const apps = await dAppStore.getAppBatch(initial_app_count, x_apps);
        const apps_count = await dAppStore.getAppCount().then(res => res.toNumber());
        console.assert(apps_count == x_apps, "app count is not correct");
        assert.isTrue(apps_count == x_apps + initial_app_count, "app count is not correct");
        // user_uploaded_apps
        user_uploaded_apps = {...user_uploaded_apps, ...apps};
    });

    it('AppBatch - Should get first app', async () =>{
        const apps_count = await dAppStore.getAppCount().then(res => res.toNumber());
        expect(apps_count).to.be.greaterThan(0);
        const app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        assert.isDefined(app, "app is not defined");
        assert.isTrue(expectAppInfo(app, 0), "app info is not correct");
    });

    it('AppBatch - Should get last app', async () =>{
        const app = await dAppStore.getAppBatch(x_apps-1, 1).then(res => res[0]);
        assert.isDefined(app, "app is not defined");
        assert.isTrue(expectAppInfo(app, x_apps - 1), "app info is not correct");
    });

    it(`AppBatch - Should get ${Math.ceil(x_apps/5)} apps from index 0 to  ${Math.ceil(x_apps/5)}`, async () => {
        const apps_num = Math.ceil(x_apps/5);
        const appBatch = await dAppStore.getAppBatch(0, apps_num);
        assert.isDefined(appBatch, "appBatch is not defined");
        expect(appBatch.length).to.equal(apps_num);

        for (i = 0; i < apps_num; i++) {
            assert.isTrue(expectAppInfo(appBatch[i], i));
        }
        const app_count = await this.DAppStore.getAppCount();
        await expect(app_count).to.equal(x_apps);
    });

    it(`AppBatch - Should get ${Math.ceil(x_apps/5)} apps from random index`, async () => {
        const apps_num = Math.ceil(x_apps/5);
        const rnd_idx = Math.floor(Math.random() * x_apps);
        const appBatch = await dAppStore.getAppBatch(rnd_idx, apps_num);
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
        const apps_count = await dAppStore.getAppCount().then(res => res.toNumber());
        // const appBatch = await dAppStore.getAppBatch(rndIdx, Math.floor(Math.random() * apps_count - 1) + 1);
        const appBatch = await dAppStore.getAppBatch(rndIdx,  apps_count);
        console.assert(appBatch.length == apps_count, "appBatch length is not correct");
        expect(appBatch.length).to.equal(apps_count);
        console.assert(parseInt(appBatch[0].id) == rndIdx, "appBatch first app is not correct");
        expect(parseInt(appBatch[0].id)).to.equal(rndIdx);
        console.assert(parseInt(appBatch[apps_count-1].id) == (rndIdx + apps_count - 1) % x_apps, "appBatch last app is not correct");
        expect(parseInt(appBatch[apps_count-1].id)).to.equal((rndIdx + apps_count - 1) % x_apps);
    });

    it('AppBatch - Get all apps when asking for more apps than appsCount', async () => {
        const rndIdx = Math.floor(Math.random() * x_apps);
        const apps_count = await dAppStore.getAppCount().then(res => res.toNumber());
        const appBatch = await dAppStore.getAppBatch(rndIdx, apps_count + Math.floor(Math.random() * 100) + 1);
        expect(appBatch.length).to.equal(apps_count);
        expect(parseInt(appBatch[0].id)).to.equal(rndIdx);
        expect(parseInt(appBatch[apps_count-1].id)).to.equal((rndIdx + apps_count - 1) % x_apps);
    });
        
    it('AppBatch - Fail to get app that doesn\'t exist', async () => {
        const apps_count = await dAppStore.getAppCount().then(res => res.toNumber());
        await dAppStore.getAppBatch(apps_count, 1).catch(err => {
            console.log('err -->', err);
            console.log('err -->', err);
            console.log('err -->', err);
            console.log('err -->', err);
        })
    });

    it('getPublishedAppsInfo - Should show all apps created by accounts[0]', async () => {
        const user_address = accounts[0];
        const apps = await dAppStore.getPublishedAppsInfo({from: user_address});
        expect(apps.length).to.equal(user_uploaded_apps.length);
        const findAppByIdInArray = (id, appArray) => {
            for (let i = 0; i < appArray.length; i++) {
                if (appArray[i].id === id) {
                    assert.isTrue(compareApps(appArray[i], user_uploaded_apps[i]));
                }
            }
        }

        for (let i = 0; i < apps.length; i++) {
            const id = user_uploaded_apps[i].id;
            const publishedApp = findAppByIdInArray(id, apps);
            expect(compareApps(user_uploaded_apps[i], publishedApp)).to.equal(true);
        }
    });

    it('getPublishedAppsInfo - Should show 0 apps created by accounts[1]', async () => {
        const user_address = accounts[1];
        const apps = await dAppStore.getPublishedAppsInfo({from: user_address});
        expect(apps.length).to.equal(0);
    });

    it('Update - Update each field individually', async () => {
        const app_id = 0;
        const app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        const new_fields = {
            id: app_id,
            name: "New name",
            description: app.description,
            imgUrl: app.imgUrl,
            magnetLink: app.magnetLink,
               
        }    
        for(field in new_fields) {
            var new_app_fields = {
                id: app_id,
                name: '',
                description: '',
                imgUrl: '',
                magnetLink: '',
                price: 0,
                fileSha256: '',
            }
            new_app_fields[field] = new_fields[field];
            await dAppStore.updateApp(new_app_fields.id,
                new_app_fields.name,
                new_app_fields.description,
                new_app_fields.imgUrl,
                new_app_fields.magnetLink,
                new_app_fields.price,
                new_app_fields.fileSha256,
                 {from: accounts[0]});
            const updated_app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
            expect(new_fields[field].toString()).to.equal(updated_app[field]);
        }  
    });

    it('UpdateApp - Update all fields', async () => {
        //todo: catch events
        const app_id = 0;
        const app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        const new_name = "new name";
        const new_description = "new description";
        const new_link = "new link";
        const new_img = "new img";
        const new_company = "new company";
        const new_price = app.price + 1;
        const new_category = "new category";
        const new_fileSha = "new fileSha";
        const new_app = {id: app.id, name: new_name, description: new_description, link: new_link, img: new_img, company: new_company, price: new_price, category: new_category, fileSha: new_fileSha};
        await dAppStore.updateApp(app_id, 
            new_name, 
            new_description, 
            new_link, 
            new_img, 
            new_price, 
            new_fileSha, {from: accounts[0]});
        const updated_app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        assert.isTrue(compareApps(new_app, updated_app), "app is not updated");
        //revert updates to app
        await dAppStore.updateApp(app_id,
            app.name,
            app.description,
            app.link,
            app.img,
            app.price,
            app.fileSha, {from: accounts[0]});
    });

    it('UpdateApp - Should not update fileSha iff update magnet link', async () => {
        //todo: make sure no events are fired off
        const app_id = 0;
        const app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        const fileSha = "new fileSha";
        const magnetLink = "magnet link";
        await dAppStore.updateApp(app_id,
            '',
            '',
            magnetLink,
            '',
            0,
            '', {from: accounts[0]});
        // truffleAssert.eventNotEmitted(result, eventType[, filter][, message])
        const updatedMagnetLink = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        assert.isTrue(compareApps(app, updatedMagnetLink), "app is not updated");

        await dAppStore.updateApp(app_id,
            '',
            '',
            '',
            '',
            0,
            fileSha, {from: accounts[0]});
        // truffleAssert.eventNotEmitted(result, eventType[, filter][, message])
        const updatedFileSha = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        assert.isTrue(compareApps(app, updatedFileSha), "app is not updated");
            
        const updateBoth = await dAppStore.updateApp(app_id,
            '',
            '',
            magnetLink,
            '',
            0,
            fileSha, {from: accounts[0]});
        // truffleAssert.eventEmitted(result, eventType[, filter][, message])
        const updatedApp = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        assert.isTrue(app.magnetLink === updatedApp.magnetLink && app.fileSha === updatedApp.fileSha, "app is not updated");

    });
        
    it('PurchaseApp - User purchases apps they don\'t own', async function () {
        const app_id = Math.floor(Math.random() * x_apps);
        const app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);;
        await dAppStore.purchaseApp(app_id, {from: accounts[1]});
        const purchased_apps = await dAppStore.getPurchasedAppsInfo({from: accounts[1]});
        assert.isTrue(compareApps(app, purchased_apps[purchased_apps.length - 1]), "app is not purchased");
    });

    it('PurchaseApp - Users purchase apps they own', async function () {
        const user = accounts[0];
        const app_id = 0;
        tx = await dAppStore.purchaseApp(app_id, {from: user}).catch(err => {
            console.log('err -->', err.msg);
        })
    });

    it('rateApp - Users rates app they don\'t own', async () => {
        const user = accoutns[5];
        const app_id = 0;
        const rating = Math.floor(Math.random() * 5);
        const unrated_rated_app = await dAppStore.getAppBatch(app_id, 1);
        expect(unrated_rated_app[0].rating).to.equal(0);


        await dAppStore.rateApp(app_id, rating, {from: user}).catch(err => {
            console.log('err -->', err.msg);
        }
        );

        // try{
        //     ;
        // }
        // catch(err){
        //     console.log('err -->', err.msg);
        // }
  });

    it('rateApp - Users rates app they own', async () => {
        const user = accounts[0];
        const app_id = 0;
        const rating = Math.floor(Math.random() * 5);
        const unrated_rated_app = await dAppStore.getAppBatch(app_id, 1);
        expect(unrated_rated_app[0].rating).to.equal(0);
        await dAppStore.rateApp(app_id, rating, {from: user});
        const rated_app = await dAppStore.getAppBatch(app_id, 1);
        expect(rated_app[0].rating).to.equal(rating);
    });

    it('rateApp - Users rates apps they own', async () => {
        var rating_sums = {};
        var rating_counts = {};
        for(var user = 0; user < accounts.length; user++){
            const purchased_apps = await dAppStore.getPurchasedAppsInfo({from: accounts[user]});
            const purchased_apps_ids = purchased_apps.map(app => app.id);
            for (var app_id = 0; app_id < x_apps; app_id++){
                const rating = Math.floor(Math.random() * 5);
                if(!purchased_apps_ids.includes(app_id)){
                    dAppStore.purchaseApp(app_id, {from: accounts[user]});
                }
                await dAppStore.rateApp(app_id, rating, {from: accounts[user]});
                if(rating_sums[app_id] === undefined){
                    rating_sums[app_id] = rating;
                    rating_counts[app_id] = 1;
                } else {
                    rating_sums[app_id] += rating;
                    rating_counts[app_id] += 1;
                }
            }
        }
        for(var app_id = 0; app_id < x_apps; app_id++){
            const avg_rating = rating_sums[app_id] / rating_counts[app_id];
            const app = await dAppStore.getAppBatch(app_id, 1);
            expect(app[0].rating).to.equal(avg_rating);
        }
    });

    it('Users get their ratings', async () => {
        assert.fail();
    });
    

});

