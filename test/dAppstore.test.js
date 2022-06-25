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
  // beforeEach(async function () {

  // });

  //Test case
  it('Should create a new dAppStore contract', async () => {
    dAppStore = await DAppStore.deployed();
    // console.log(`dAppStore address: ${dAppStore.address}`);
    // console.log(`dAppStore receipt: ${dAppStore.receipt}`);
    assert.isOk(dAppStore.address);
  });  
  // it('Create single app', async () => {
  //   const name = "name" + `${0}`;
  //   const description = "description";
  //   const link = "link";
  //   const img = "img";
  //   const company = "company";
  //   const price = 8;
  //   const category = "category";
  //   const fileSha = "fileSha0";
  //   const user_address = accounts[0];
  //   const app = await dAppStore.createNewApp(
  //     name,
  //     description,
  //     link,
  //     img,
  //     company,
  //     price,
  //     category,
  //     fileSha,
  //     { from: user_address }
  //   );
  //   console.log(`app: ${app}`);
  //   assert.isOk(app);
  //   const app0 = await dAppStore.getAppBatch(0, 1);
  //   console.log(`app0: ${app0}`);

  // });
  it(`Create ${x_apps} apps for same user`, async () => {
      const user_address = accounts[0];
      for (let i = 0; i < x_apps; i++) {
        console.log(`Creating app ${i}`);
        const idx = `${i}`;
        const name = "name" + idx;
        const description = "description";
        const link = "link";
        const img = "img";
        const company = "company";
        const price = 8;
        const category = "category";
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
      const apps_count = await dAppStore.getAppsCount();
      expect(apps_count).to.be.equal(x_apps);
    });

  it('Should get first app', async () =>{
    console.log('get first app');
    const app = await dAppStore.getAppBatch(0, 1);
    console.log(app);
    expect(app[0].id).to.equal(0);
    expect(app[0].name).to.equal('name0');
    expect(app[0].description).to.equal('description0');
    expect(app[0].link).to.equal('link0');
    expect(app[0].img).to.equal('img0');
    expect(app[0].company).to.equal('company0');
    expect(app[0].price).to.equal(8);
    expect(app[0].category).to.equal('category0');
    expect(app[0].fileSha).to.equal('fileSha0');
  });
  it('Should get last app', async () =>{
    console.log('get last app');
    const app = await dAppStore.getAppBatch(x_apps-1, 1);
    console.log(app);
    expect(app[0].id).to.equal(x_apps-1);
    expect(app[0].name).to.equal(`name${x_apps-1}`);
    expect(app[0].description).to.equal(`description${x_apps-1}`);
    expect(app[0].link).to.equal(`link${x_apps-1}`);
    expect(app[0].img).to.equal(`img${x_apps-1}`);
    expect(app[0].company).to.equal(`company${x_apps-1}`);
    expect(app[0].price).to.equal(8);
    expect(app[0].category).to.equal(`category${x_apps-1}`);
    expect(app[0].fileSha).to.equal(`fileSha${x_apps-1}`);
  });
  it(`Should get ${Math.ceil(x_apps/5)} apps from index 0 to  ${Math.ceil(x_apps/5)}`, async () => {
    const apps_num = Math.ceil(x_apps/5);
    console.log('get apps form index 0 to ' + apps_num);
    const appBatch = await dAppStore.getAppBatch(0, apps_num);
    console.log(appBatch);
    expect(appBatch.length).to.equal(apps_num);

    for (i = 0; i < apps_num; i++) {
      expect(appBatch[i].id).to.equal(i);
      expect(appBatch[i].name).to.equal(`name${i*5}`);
      expect(appBatch[i].description).to.equal(`description${i*5}`);
      expect(appBatch[i].link).to.equal(`link${i*5}`);
      expect(appBatch[i].img).to.equal(`img${i*5}`);
      expect(appBatch[i].company).to.equal(`company${i*5}`);
      expect(appBatch[i].price).to.equal(8);
      expect(appBatch[i].category).to.equal(`category${i*5}`);
      expect(appBatch[i].fileSha).to.equal(`fileSha${i*5}`);
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
      expect(appBatch[i].id).to.equal((i+rnd_idx) % x_apps);
      expect(appBatch[i].name).to.equal(`name${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].description).to.equal(`description${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].link).to.equal(`link${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].img).to.equal(`img${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].company).to.equal(`company${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].price).to.equal(8);
      expect(appBatch[i].category).to.equal(`category${(i+rnd_idx) % x_apps}`);
      expect(appBatch[i].fileSha).to.equal(`fileSha${(i+rnd_idx) % x_apps}`);
      }
  });
  it('Get user published apps', async function () {
    const user_address = accounts[0];
    const apps = await dAppStore.getUserApps(user_address);
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


