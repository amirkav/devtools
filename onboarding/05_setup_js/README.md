# Frontend Setup

## Setup npm

### Install NVM (Recommended)
Run the script in terminal

Node Version Manager (NVM) is a tool we use to manage our system node versions.

### Install Node

After running the script, install node

#### Install Node v14 (Update on 2021-05-13, v14 works with both Flavius & external-site)
```bash
nvm install v14
```

#### Install Node v10 (Recommend also install v10, in case some legacy app requires v10)
```bash
nvm install v10
```

You may also want to install multiple other node versions, be careful when working with the latest version.

Check existing node versions by running `nvm list`

Validate you have node install by running: `node --version`

## Clone flavius (web app)
1. Clone the [flavius repo](https://github.com/altitudenetworks/flavius)
2. Install Dependencies: `npm install`
3. Start the local server: `npm run start`

## Clone external-site (marketing)
1. Clone the [external-site repo](https://github.com/altitudenetworks/external-site)
2. Install dependencies: `npm install`
3. Start the local server: `npm run start`
