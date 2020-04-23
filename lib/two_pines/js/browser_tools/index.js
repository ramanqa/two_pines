const BrowserTools = require('./src/browser-tools.js').BrowserTools,
      express = require('express'),
      app = express();

var port = 3000,
    browserDebugUrl = "http://localhost:9000";

process.argv.forEach((item)=>{
  if(item.startsWith("--")){
    if(item.split("=")[0].split("--")[1] == "port"){
      port = item.split("=")[1];
    }
    if(item.split("=")[0].split("--")[1] == "browserDebugUrl"){
      browserDebugUrl = item.split("=")[1];
    }
  }
});

const browserTools = new BrowserTools(browserDebugUrl);

app.use(express.json());

app.post('/sniff', (req, res, next) => {
    browserTools
      .sniff(req.body.url)
        .then(response => res.send(response))
        .catch(failure => res.send(failure));
  });
app.post('/sniff_ending_with', (req, res, next) => {
    browserTools
      .sniff_ending_with(req.body.url)
        .then(response => res.send(response))
        .catch(failure => res.send(failure));
  });

app.get('/screenshot', (req, res) => {
    browserTools
      .captureFullPageScreenshot()
        .then(response => res.send(response))
        .catch(failure => res.send(failure));
});

app.listen(port, () => console.log('BrowserTools listening at port ' + port + '\n  - browserDebugUrl: ' + browserDebugUrl));

