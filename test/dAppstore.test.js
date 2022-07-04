var chai = require("chai");
const expect = chai.expect;
const assert = chai.assert;

const DAppStore = artifacts.require("dAppstore");

// Start test block
contract('dAppStore', (accounts) => {
  const x_apps = 10;
  let user_uploaded_apps = [];
  const user_address = accounts[0];
  let dAppStore;
  const expectAppInfo = (app, id, price = 8) =>{
    console.assert(app.id.toNumber() == id, "app id is not correct");
    console.assert(app.name == `name${id}`, "app name is not correct");
    console.assert(app.description == `description${id}`, "app description is not correct");
    console.assert(app.link == `link${id}`, "app link is not correct");
    console.assert(app.img == `img${id}`, "app img is not correct");
    console.assert(app.company == `company${id}`, "app company is not correct");
    console.assert(app.price.toNumber() == price, "app price is not correct");
    console.assert(app.category == `category${id}`, "app category is not correct");
    console.assert(app.fileSha == `fileSha${id}`, "app fileSha is not correct");
    
    expect(app.id).to.equal(id.toString());
    expect(app.name).to.equal(`name${id}`);
    expect(app.description).to.equal(`description${id}`);
    expect(app.link).to.equal(`link${id}`);
    expect(app.img).to.equal(`img${id}`);
    expect(app.company).to.equal(`company${id}`);
    expect(app.price).to.equal(price.toString());
    expect(app.category).to.equal(`category${id}`);
    expect(app.fileSha).to.equal(`fileSha${id}`);
}

  //Test case
  it('Should create a new dAppStore contract', async () => {
    dAppStore = await DAppStore.deployed();
    // console.log(`dAppStore address: ${dAppStore.address}`);
    // console.log(`dAppStore receipt: ${dAppStore.receipt}`);
    assert.isOk(dAppStore.address);
    const user_address = accounts[0];
      for (let i = 0; i < x_apps; i++) {
        console.log(`Creating app ${i}`);
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
        );
      }

  });  
//   it('Create single app', async () => {
//     const name = "name" + `${0}`;
//     const description = "description" + `${0}`;
//     const link = "link" + `${0}`;
//     const img = "img" + `${0}`;
//     const company = "company" + `${0}`;
//     const price = 8;
//     const category = "category" + `${0}`;
//     const fileSha = "fileSha0" + `${0}`;
//     const user_address = accounts[0];
//     const app = await dAppStore.createNewApp(
//       name,
//       description,
//       link,
//       img,
//       company,
//       price,
//       category,
//       fileSha,
//       { from: user_address }
//     );
//     console.log(`app: ${app}`);
//     assert.isOk(app);
//     const app0 = await dAppStore.getAppBatch(0, 1);
//     console.log(`app0: ${app0}`);

//   });
  it(`Create ${x_apps} apps for same user`, async () => {
    const initial_app_count = await dAppStore.getAppCount();
      const user_address = accounts[0];
      for (let i = 0; i < x_apps; i++) {
        console.log(`Creating app ${i}`);
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
        );
      }
      const apps = await dAppStore.getAppBatch(0, x_apps);
      // console.log(`apps: ${apps}`);
      const apps_count = await dAppStore.getAppCount();
      console.log(`apps_count: ${apps_count}`);
      expect(apps_count.toNumber()).to.be.equal(x_apps  + initial_app_count.toNumber());
    });
  it('Should get first app', async () =>{
    const app = await dAppStore.getAppBatch(0, 1);
    console.log(`first app: ${app}`);
    expectAppInfo(app, 0);
    
  });
  it('Should get last app', async () =>{
    const app = await dAppStore.getAppBatch(x_apps-1, 1);
    console.log(`last app: ${app}`);
    expectAppInfo(app, x_apps-1);
  });
  it(`Should get ${Math.ceil(x_apps/5)} apps from index 0 to  ${Math.ceil(x_apps/5)}`, async () => {
    const apps_num = Math.ceil(x_apps/5);
    console.log('get apps form index 0 to ' + apps_num);
    const appBatch = await dAppStore.getAppBatch(0, apps_num);
    console.log(appBatch);
    expect(appBatch.length).to.equal(apps_num);

    for (i = 0; i < apps_num; i++) {
        expectAppInfo(app, i);
    }
  });
  it (`Should get ${Math.ceil(x_apps/5)} apps from random index`, async () => {
    const apps_num = Math.ceil(x_apps/5);
    const rnd_idx = Math.floor(Math.random() * x_apps);
    console.log('get apps form random index to ' + apps_num);
    const appBatch = await dAppStore.getAppBatch(rnd_idx, apps_num);
    console.log(appBatch);
    expect(appBatch.length).to.equal(apps_num);

    for (i = 0; i < apps_num; i++) {
      expect(parseInt(appBatch[i].id)).to.equal((i+rnd_idx) % x_apps);
      expect(appBatch[i].name).to.equal(`name${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].description).to.equal(`description${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].link).to.equal(`link${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].img).to.equal(`img${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].company).to.equal(`company${(i+rnd_idx) % x_apps}`);
      expect(parseInt(app[0].price)).to.equal(8);
      expect(appBatch[i].category).to.equal(`category${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].fileSha).to.equal(`fileSha${(i+rnd_idx) % x_apps}`);
      }
  });
  it('Get user published apps', async function () {
    const user_address = accounts[0];
    const apps = await dAppStore.getPublishedAppsInfo(user_address);
    expect(apps.length).to.equal(user_uploaded_apps.length);
    const findAppByIdInArray = (id, appArray) => {
      for (let i = 0; i < appArray.length; i++) {
        if (appArray[i].id === id) {
          return appArray[i];
          }
        }
      }
    const compareApps = (app1, app2) => {
      return app1.id === app2.id &&
        app1.name === app2.name &&
        app1.description === app2.description &&
        app1.link === app2.link &&
        app1.img === app2.img &&
        app1.company === app2.company &&
        app1.price === app2.price &&
        app1.category === app2.category &&
        app1.fileSha === app2.fileSha;
    }
    for (let i = 0; i < apps.length; i++) {
      const id = user_uploaded_apps[i].id;
      const publishedApp = findAppByIdInArray(id, apps);
      expect(compareApps(user_uploaded_apps[i], publishedApp)).to.equal(true);
    }
  });
  it('Update App', async function () {

  });

  it('Users purchases app', async function () {
      // assert(1>256);
  });
  it('Users rate apps', async function () {
    
  });

  });


