const puppeteer = require('puppeteer-core');

exports.BrowserTools = class {

  constructor(browserDebugUrl){
    this.browserDebugUrl = browserDebugUrl;
    var self = this;
    puppeteer.connect({browserURL: this.browserDebugUrl, defaultViewport: null})
      .then(chromeTools => self.chromeTools = chromeTools);
  }

  sniff(requestPath){
    var self = this;
    console.log("Sniffing " + requestPath);
    return new Promise((resolve, reject)=>{
      self.chromeTools.pages()
        .then(pages => {
          var page = pages[0];
          page.on('response', response => {
            if(response.url().includes(requestPath)){
              response.text()
                .then(body => {
                  console.log("Recieved " + response.url());
                  resolve(body);
                });
            }
          });
        })
        .catch(error => {console.log(error);reject(error)});
    });
  }
  sniff_ending_with(requestPath){
    var self = this;
    console.log("Sniffing " + requestPath);
    return new Promise((resolve, reject)=>{
      self.chromeTools.pages()
        .then(pages => {
          var page = pages[0];
          page.on('response', response => {
            if(response.url().endsWith(requestPath)){
              response.text()
                .then(body => {
                  console.log("Recieved " + response.url());
                  resolve(body);
                });
            }
          });
        })
        .catch(error => {console.log(error);reject(error)});
    });
  }

  captureFullPageScreenshot(){
    var self = this;
    return new Promise((resolve, reject)=>{
      self.chromeTools.pages()
        .then(pages => {
          var page = pages[0]
          page.screenshot({
            fullPage: true,
            encoding: 'base64'
          })
            .then(imageBase64=>{
              resolve(imageBase64);
            })
            .catch(failure => reject(failure));
        })
        .catch(error => {console.log(error);reject(error)});
    });
  }
}

