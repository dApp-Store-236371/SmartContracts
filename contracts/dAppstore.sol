pragma solidity ^0.8.13;
// SPDX-License-Identifier: UNLICENSED
contract dAppStore {

    struct App {
        uint256  id;
        string  name;
        string  description;
        address  creator;
        string[]  fileSha256; //last is SHA of latest version.
        string magnetLink;
        string imgUrl;
        string company;
        int  rating; //-1 means not rated
        uint price; //in wei
    }

   modifier onlyCreator(uint id) {
        require(appPublishedMapping[id][msg.sender] == true, "Caller is not the app's creator.");
        _; //ensures the rest of the function will continue to execute if passes
    }

    modifier onlyPurchaser(uint id) {
        require(appBoughtMapping[id][msg.sender] == true, "Caller has not purchased the app.");
        _;
    }

    App[] public apps; //index is the 'id' of the app. Index zero must not be used!
    uint[]public ratingOrderedApps; //app indexes ordered by rating. 

    /* To know if purchased/bought */
    mapping (uint => mapping (address => bool)) appBoughtMapping; // App index => addresses => true iff purchased.
    mapping (uint => mapping (address => bool)) appPublishedMapping; // App index => addresses => true iff published.

    /* To get list of apps */
    mapping (address => uint[]) public purchasedListMapping;// address of buyer => indexes of purchased apps
    mapping (address => uint[]) public publishedListMapping; //address of seller => indexes of published apps

    mapping (address => mapping( uint => uint)) public personalRatings; //adress of buyer => id of app => rating.
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
                creator: msg.sender                     
            });

        publishedListMapping[msg.sender].push(app.id);
        appPublishedMapping[app.id][msg.sender] = true;

        apps.push(app);
        apps[index].fileSha256.push(_fileSha256);
        ratingOrderedApps.push(app.id);
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

    function getApps(uint from, uint to) public view returns (App[] memory res, uint totalNumOfApps){
        require(from > 0 && to > 0 && to < apps.length, "Invalid Range");

        uint counter = 0;
        for(uint i = from; i < to; i++){
            //Populates res, while removing magnet links if not bought
            res[counter] = (apps[i]);
            if(!appBoughtMapping[i][msg.sender]){
                res[counter].magnetLink = "";
            }
            counter++;
        }
        
        totalNumOfApps = apps.length;
    }

}
