const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');
const sha3 = require('js-sha3').keccak_256;
const keccak256 = require('keccak256')
var chai = require("chai");
const { catchRevert } = require('./exceptions');
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

    const calcRating = (ratingInt, ratingModulu, numRatings) => {
        if (numRatings === '0') {
            return 0;
        }
        const num = parseInt(numRatings);
        const int = parseInt(ratingInt);
        const modulu = parseInt(ratingModulu);
        // console.log('num:', num, ' int:', int, 'modulu: ', modulu);
        return int / num + modulu;
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

        const appNotOwned = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        assert.isDefined(appNotOwned, "app is not defined");
        assert.isTrue(expectAppInfo(appNotOwned, 0), "app info is not correct");
    });

    it('AppBatch - Should get last app', async () =>{
        const app = await dAppStore.getAppBatch(await dAppStore.getAppCount()-1, 1).then(res => res[0]);
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
        const app_count = await dAppStore.getAppCount().then(res => res.toNumber());
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
        await catchRevert(dAppStore.getAppBatch(apps_count, 1, {from: accounts[0]}))
    });

    it('getPublishedAppsInfo - Should show all apps created by accounts[0]', async () => {
        const user_address = accounts[0];
        const apps = await dAppStore.getPublishedAppsInfo({from: user_address});
        expect(apps.length).to.equal(Object.keys(user_uploaded_apps).length);
        const findAppByIdInArray = (id, appArray) => {
            // console.log('appArray not undefind', appArray !== undefined);
            for (let i = 0; i < appArray.length; i++) {
                // console.log('appArray[i]-->', i)
                if (appArray[i].id === id) {
                    assert.isTrue(compareApps(appArray[i], user_uploaded_apps[i]));
                }
            }
        }
        console.log('appArray not undefined-->', user_uploaded_apps);
        for (let i = 0; i < apps.length; i++) {
            const id = parseInt(user_uploaded_apps[i][0]);
            console.log('user_uploaded_apps[i]-->', i);
            console.log('user_uploaded_apps[i]--->', user_uploaded_apps[i]);
            const publishedApp = findAppByIdInArray(id, apps);
            // expect(compareApps(user_uploaded_apps[i], publishedApp)).to.equal(true);
        }
    });

    it('getPublishedAppsInfo - Should show 0 apps created by accounts[1]', async () => {
        const user_address = accounts[1];
        const apps = await dAppStore.getPublishedAppsInfo({from: user_address});
        expect(apps.length).to.equal(0);
    });



    
    it("UpdateApp - update nothing", async () => {
        const original_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const updated  = await dAppStore.updateApp(
            0,
            '',
            '',
            '',
            '',
            0,
            '');
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        compareApps(original_app, updated_app);
    });
    
    it("UpdateApp - update name", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_name = "new_name" + app.id;
        const tx = await dAppStore.updateApp(
          app.id,
          new_name,
          '',
          '',
          '',
          0,
          '');
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.name).to.equal(new_name);
    });

    it("UpdateApp - update description", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_description = "new_description" + app.id;
        const tx = await dAppStore.updateApp(
            app.id,
            '',
            new_description,
            '',
            '',
            0,
            '');
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.description).to.equal(new_description);
    });

    it("UpdateApp - update imgUrl", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_url = "new_img" + app.id;
        const tx = await dAppStore.updateApp(
            app.id,
            '',
            '',
            '',
            new_url,
            0,
            '');
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.imgUrl).to.equal(new_url);
        expect(app.id).to.equal(updated_app.id);
        expect(app.name).to.equal(updated_app.name);
        expect(app.description).to.equal(updated_app.description);
        expect(app.magnetLink).to.equal(updated_app.magnetLink);
        expect(app.fileSha256).to.equal(updated_app.fileSha256);
        expect(app.price).to.equal(updated_app.price);
    });
      
    it("UpdateApp - update price", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_price = Math.floor(Math.random() * 100 + 1);
        const tx = await dAppStore.updateApp(
            app.id,
            '',
            '',
            '',
            '',
            new_price,
            '');
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.price).to.equal(new_price.toString());
    });

    it("UpdateApp - fail update just magnetLink", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_magnetLink = "new_magnetLink" + app.id;
        await catchRevert(dAppStore.updateApp(
            app.id,
            '',
            '',
            new_magnetLink,
            '',
            0,
            ''));
    });

    it("UpdateApp - fail update just fileSha256", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_fileSha256 = "new_fileSha256" + app.id;
        await catchRevert(dAppStore.updateApp(
            app.id,
            '',
            '',
            '',
            '',
            0,
            new_fileSha256));
    });

    it("UpdateApp - update new version", async () => {
        app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        const new_magnetLink = "new_magnetLink" + app.id;
        const new_fileSha256 = "new_fileSha256" + app.id;
        const tx = await dAppStore.updateApp(
            app.id,
            '',
            '',
            new_magnetLink,
            '',
            0,
            new_fileSha256);
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.magnetLink).to.equal(new_magnetLink);
        expect(updated_app.fileSha256).to.equal(new_fileSha256);
    });

    it("updates all  fields", async () => { 
        const app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        
        const new_fileSha = "filesha" + app.id;
        const new_name = "name" + app.id;
        const new_description = "description" + app.id;
        const new_img = "img" + app.id;
        const new_link = "link" + app.id;
        const new_price = 8;
        await dAppStore.updateApp(
            app.id,
            new_name,
            new_description,
            new_link,
            new_img,
            new_price,
            new_fileSha
        )
    
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(updated_app.name).to.equal(new_name);
        expect(updated_app.description).to.equal(new_description);
        expect(updated_app.magnetLink).to.equal(new_link);
        expect(updated_app.imgUrl).to.equal(new_img);
        expect(updated_app.price).to.equal(new_price.toString());
        expect(updated_app.fileSha256).to.equal(new_fileSha);
    });

    it("rateApp - give app new rating and change it", async () => {
        const app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(calcRating(app.ratingInt, app.ratingModulu, app.numRatings)).to.equal(0);
        const new_rating = Math.floor(Math.random() * 5 + 1);
        const tx = await dAppStore.rateApp(app.id, new_rating);
        const updated_app = await dAppStore.getAppBatch(0, 1).then(res => res[0]);
        expect(calcRating(updated_app.ratingInt, updated_app.ratingModulu, updated_app.numRatings)).to.equal(new_rating);
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
        catchRevert(await dAppStore.purchaseApp(app_id, {from: user}));

    });

    it('rateApp - Users rates app they don\'t own', async () => {
        const user = accounts[5];
        const app_id = 0;
        const rating = Math.floor(Math.random() * 5);
        const app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
        catchRevert(await dAppStore.rateApp(app_id, rating, {from: user}));
        expect(parseInt(app.userRating)).to.equal(0);

  });

});


  //
  //   it('rateApp - Users rates app they own', async () => {
  //       const user = accounts[0];
  //       const app_id = 0;
  //       const rating = Math.floor(Math.random() * 5);
  //       const unrated_rated_app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
  //       expect(parseInt(unrated_rated_app.userRating)).to.equal(0);
  //       await dAppStore.rateApp(app_id, rating, {from: user});
  //       const rated_app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
  //       expect(parseInt(rated_app.userRating)).to.equal(rating);
  //   });
  //
  //   it('rateApp - Users rates apps they own', async () => {
  //       var rating_sums = {};
  //       var rating_counts = {};
  //       for(var user = 0; user < accounts.length; user++){
  //           const purchased_apps = await dAppStore.getPurchasedAppsInfo({from: accounts[user]});
  //           const purchased_apps_ids = purchased_apps.map(app => app.id);
  //           for (var app_id = 0; app_id < x_apps; app_id++){
  //               const rating = Math.floor(Math.random() * 5);
  //               if(!purchased_apps_ids.includes(app_id)){
  //                   dAppStore.purchaseApp(app_id, {from: accounts[user]});
  //               }
  //               await dAppStore.rateApp(app_id, rating, {from: accounts[user]});
  //               if(rating_sums[app_id] === undefined){
  //                   rating_sums[app_id] = rating;
  //                   rating_counts[app_id] = 1;
  //               } else {
  //                   rating_sums[app_id] += rating;
  //                   rating_counts[app_id] += 1;
  //               }
  //           }
  //       }
  //       for(var app_id = 0; app_id < x_apps; app_id++){
  //           const avg_rating = rating_sums[app_id] / rating_counts[app_id];
  //           const app = await dAppStore.getAppBatch(app_id, 1).then(res => res[0]);
  //           const app_rating = calc
  //           expect(calcRating(app.ratingInt, app.ratingModulu, app.numRatings)).to.equal(avg_rating);
  //       }
  //   });
