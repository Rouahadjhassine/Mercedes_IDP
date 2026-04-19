const api = require('@backstage/frontend-plugin-api');
console.log(Object.keys(api).filter(k => k.toLowerCase().includes('signin')));
