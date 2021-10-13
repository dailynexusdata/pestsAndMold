const fs = require('fs');
const pdfParse = require('pdf-parse');

const data = fs.readFileSync('src/data/pra/Pest Control Report HDAE 2021.pdf');

(async () => {
  const d = await pdfParse(data);

  console.log(d.text.replace(/\n/, ' '));
})();
