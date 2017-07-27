import React, { Component } from 'react';
import HodlTokenContract from '../build/contracts/HodlToken.json';
import getWeb3 from './utils/getWeb3';

import './css/oswald.css';
import './css/open-sans.css';
import './css/pure-min.css';
import './App.css';

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      web3: null,
      hodlTokenAddress: null,
    };
  }

  async componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    var web3 = await getWeb3;
    this.setState({web3: web3.web3});
    await this.instantiateContract();
  }

  async instantiateContract() {
    // Right now we're only using this to get the hodlToken address
    // but we may use it later to build a UI for withdrawing / depositing.
    const contract = require('truffle-contract');
    const hodlToken = contract(HodlTokenContract);
    hodlToken.setProvider(this.state.web3.currentProvider);

    var hodlTokenInstance = await hodlToken.deployed();
    this.setState({hodlTokenAddress: hodlTokenInstance.address});
  }

  render() {

    var address = this.state.hodlTokenAddress || "Loading...";

    return (
      <div className="App">
        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>HodlHard</h1>
              <p>HodlHard Token address: {address}</p>
             </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App;
