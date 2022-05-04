pragma solidity ^0.8.13;
// SPDX-License-Identifier: UNLICENSED
contract dAppStore {

    struct App {
        uint256  id;
        string  name;
        string  description;
        address payable  creator;
        string[]  fileSha256; //last is SHA of latest version.
        string magnetLink;
        string imgUrl;
        string company;
        int  rating; //-1 means not rated
        uint price; //in wei
        uint RatingsNum;

        bool owned; //will be filled by getter functions.
        int myRating;
    }

    

   modifier onlyCreator(uint id) {
        require(appPublishedMapping[id][msg.sender] == true, "Caller is not the app's creator.");
        _; //ensures the rest of the function will continue to execute if passes
    }

    modifier onlyPurchaser(uint id) {
        require(appBoughtMapping[id][msg.sender] == true, "Caller has not purchased the app.");
        _;
    }

    modifier onlyNotPurchaser(uint id) {
        require(appBoughtMapping[id][msg.sender] == false, "Caller has already purchased the app.");
        _;
    }

    constructor() {
        App memory app;
        apps.push(app);//We want to use 1-based indexing because mappings return zero when it doesn't exist.
    }

    App[] public apps; //index is the 'id' of the app. Index zero must not be used!
    uint[]public ratingOrderedApps; //app indexes ordered by rating. 

    /* To know if purchased/bought */
    mapping (uint => mapping (address => bool)) appBoughtMapping; // App index => addresses => true iff purchased.
    mapping (uint => mapping (address => bool)) appPublishedMapping; // App index => addresses => true iff published.

    /* To get list of apps */
    mapping (address => uint[]) public purchasedListMapping;// address of buyer => indexes of purchased apps
    mapping (address => uint[]) public publishedListMapping; //address of seller => indexes of published apps

    mapping (address => mapping( uint => int)) public personalRatings; //adress of buyer => id of app => rating.
                                                                  // Not in App struct because structs with nested mapping must use storage.
    function upload(string memory _name, string memory _description, string memory _fileSha256,
            string memory _imgUrl, string memory _magnetLink, string memory _company, uint _price) public { 
    
        require(bytes(_description).length <= 256, "Description must be at most 256 characters long");
        require(_price > 0, "No free apps allowed"); //TODO: Implement as a feature?

         string[] memory dummyShaArr;
         uint index = apps.length;
         App memory app = App(
             {
                id: index, //Maybe redundant.
                name:_name,
                description: _description,
                fileSha256: dummyShaArr, 
                imgUrl: _imgUrl,
                magnetLink: _magnetLink,
                company: _company,
                price: _price,
                rating: -1,
                creator: payable(msg.sender),
                owned: false,
                myRating: -1,
                RatingsNum: 0               
            });

        //Store mapping about the uploader
        publishedListMapping[msg.sender].push(app.id);
        appPublishedMapping[app.id][msg.sender] = true;

        //Uploader owns his own app
        appBoughtMapping[app.id][msg.sender] = true;
        purchasedListMapping[msg.sender].push(app.id);
        personalRatings[msg.sender][app.id] = -1; //not rated

        apps.push(app);
        apps[index].fileSha256.push(_fileSha256);
        ratingOrderedApps.push(app.id);

    }

    function purchase(uint id) public payable onlyNotPurchaser(id)  { 
        require(id > 0 && id < apps.length);
        App memory app = apps[id];
        require(app.price == msg.value, "Not enough/too much ether sent");
        (bool sent,) = app.creator.call{value: msg.value}(""); //sends ether to the creator
        require(sent, "Failed to send Ether");
        
        
        appBoughtMapping[id][msg.sender] = true;
        purchasedListMapping[msg.sender].push(id);
        personalRatings[msg.sender][id] = -1; //not rated

    } 

    function update(uint id, string calldata description, string calldata fileSha256,
            string calldata imgUrl, string calldata magnetLink, uint price) public onlyCreator(id) {
                
                require(bytes(description).length <= 256, "Description must be at most 256 characters long");
                require(id < apps.length, "No app with this ID exists.");
                require(price > 0, "No free apps allowed"); //TODO: Implement as a feature?

                apps[id].description = description;
                apps[id].fileSha256.push(fileSha256);
                apps[id].imgUrl = imgUrl;
                apps[id].magnetLink = magnetLink;
                apps[id].price = price;
            }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a >= b ? b : a;
    }

    //Returns apps from given index to given index, with download data to users who purchased the app.
    //TODO: filtering. maybe.
    function getApps(uint from, uint to, address fetcher) public view returns (App[] memory result, uint totalNumOfApps){
        

        require(from > 0 && from < to, "Invalid Range");
        to = min(to, apps.length);
        result =  new App[](to-from);

        uint counter = 0;
        for(uint i = from; i < to; i++){
            //Populates res, while removing magnet links if not bought
            result[counter] = apps[i];

            result[counter].myRating = personalRatings[fetcher][i];
            if(!appBoughtMapping[i][fetcher]){
                result[counter].magnetLink = "";
                //owned is false by default
            }
            else{
                result[counter].owned = true;
            }
            counter++;
        }
        

        totalNumOfApps = apps.length;
    }

    //returns apps purchased by the sender.
    function getPurchasedApps(address owner) public view returns (App[] memory purchasedApps){
        uint[] memory purchasedAppsIndexes = purchasedListMapping[owner];
        purchasedApps =  new App[](purchasedAppsIndexes.length);
        uint counter = 0;
        for(uint i=0; i < purchasedApps.length; i++){
            purchasedApps[counter] = apps[purchasedAppsIndexes[i]];
              purchasedApps[counter].owned = true;
            counter++;
        }
    }

    //returns apps published by the sender.
    function getPublishedApps(address publisher) public view returns (App[] memory publishedApps){
        uint[] memory publishedAppsIndexes = publishedListMapping[publisher];
        publishedApps = new App[](publishedAppsIndexes.length);
        uint counter = 0;
        for(uint i=0; i < publishedAppsIndexes.length; i++){
            publishedApps[counter] = apps[publishedAppsIndexes[i]];
             publishedApps[counter].owned = true;
            counter++;
        }
    }

    function getMagnetLink(uint appId) public view returns (string memory){
        for(uint i=0; i < apps.length; i++){
            if (apps[i].id == appId){
                return apps[i].magnetLink;
            }
        }
        return "";
    }

    function setMagnetLink(uint appId, string memory magnetLink) public returns (uint) {
        for(uint i=0; i < apps.length; i++){
            if(apps[i].id == appId){
                apps[i].magnetLink = magnetLink;
                return 0;
            }
        }
        return 1;
    }

}
