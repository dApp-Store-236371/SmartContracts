const { expect } = require('chai');
const BN = require('bn.js');
const App = artifacts.require("App");
const DEBUG = true;
// Start test block
contract('App contract', (accounts) => {
  let app;
  // console.log(`number of accounts: ${accounts.length}`);
  function calcRating(rating_int, rating_modulu, num_ratings){
    // console.log(`ratingInt: ${rating_int} ratingModulu: ${rating_modulu} numRating: ${num_ratings}`);
    if (num_ratings == 0 ) {
      return 0;
    }
    return rating_int + rating_modulu / num_ratings;
  }
  
  function ArrayAverage(array){
    let length = 0;
    let sum = 0;  
    for (let i = 0; i < array.length; i++) {
      sum += array[i];
      if (array[i] > 0){
        length++;
      }
  }
  console.log(`length: ${length} sum: ${sum} values: ${array}`);
  return sum / length;
  }

  beforeEach(async function () {
      const fileSha = "fileSha0";
      const price = 8;
      const company = "company";
      const img = "img";
      const link = "link";
      const description = "description";
      const name = "name";
      const user_address = "0x0000000000000000000000000000000000000000";
      const category = "category";
      const app_id = 0;
    // Deploy a new Box contract for each test
    app = await App.new(
      app_id,
      user_address,
      name,
      description,
      link,
      img,
      company,
      price,
      category,
      fileSha
    );


  });

  // Test case for app updates
  it("updates all  fields", async () => { 
    const new_fileSha = "new filesha";
    const new_name = "new name";
    const new_description = "new description";
    const new_img = "new img";
    const new_link = "new link";
    const new_price = 9;
    await app.updateApp(
      new_name,
      new_description,
      new_link,
      new_img,
      new_price,
      new_fileSha
    )

    expect(await app.name()).to.equal(new_name);
    expect(await app.description()).to.equal(new_description);
    expect(await app.imgUrl()).to.equal(new_img);
    expect(await app.magnetLink()).to.equal(new_link);
    expect(await app.getCurrentVersion()).to.equal(new_fileSha);
    const price = await app.price.call()
    console.log(typeof price.toNumber());
    expect(price.toNumber()).to.equal(new_price);
  });

  it('test rating updates', async () => {
    console.log(`number of accounts: ${accounts.length}`);
    let appInfo;
    let appRating;
    let currentRating;

    const num_users = 10;
    const num_iterations = 10;
    let user_rating = new Array(num_users).fill(0);
    console.log('setting user_rating and comparing averages');
    for (let i = 0; i < num_iterations; i++) {
      const new_rating = Math.floor(Math.random() * 5) + 1; 
      const user = Math.floor(Math.random() *10);
      await app.rateApp(new_rating, user_rating[user]); // account i rates rnd from 0
      user_rating[user] = new_rating;
      console.log(new_rating, i, user_rating);
    }

    appInfo = await app.getAppInfo.call(true, 1);
    
    appRating = calcRating(parseInt(appInfo.ratingInt), parseInt(appInfo.ratingModulu), parseInt(appInfo.numRatings));
    //calculate average calue of array user_rating
    const user_rating_average = ArrayAverage(user_rating);
    expect(appRating).to.be.closeTo( user_rating_average, 0.001);  

    console.log('changing user_rating and comparing averages');


    
  })
})

