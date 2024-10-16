// const fs = require('fs');
// const https = require('https');

// const url = 'https://api.fda.gov/drug/label.json?limit=10';

// https.get(url, (resp) => {
//     let data = '';

//     // A chunk of data has been received.
//     resp.on('data', (chunk) => {
//         data += chunk;
//     });

//     // The whole response has been received.
//     resp.on('end', () => {
//         fs.writeFileSync('drugs.json', data);
//         console.log('File saved!');
//     });

// }).on("error", (err) => {
//     console.log("Error: " + err.message);
// });

const fs = require('fs');
const https = require('https');

// API URL for 1000 drugs
const url = 'https://api.fda.gov/drug/label.json?limit=10';

// Function to extract the relevant fields
function extractDrugInfo(data) {
    return data.results.map(drug => {
        return {
            name: drug.openfda.brand_name ? drug.openfda.generic_name[0] : 'N/A',
            chemical_ingredients: drug.openfda.substance_name ? drug.openfda.substance_name : 'N/A',
            uses: drug.purpose ? drug.purpose[0] : 'N/A',
            warnings: drug.warnings ? drug.warnings[0] : 'N/A',
            dose: drug.dosage_and_administration ? drug.dosage_and_administration[0] : 'N/A',
            image_url: drug.openfda.image_url ? drug.openfda.image_url[0] : 'N/A'
        };
    });
}

https.get(url, (resp) => {
    let data = '';

    // A chunk of data has been received
    resp.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received
    resp.on('end', () => {
        const jsonData = JSON.parse(data);
        const filteredData = extractDrugInfo(jsonData);

        fs.writeFileSync('drugs1.json', JSON.stringify(filteredData, null, 2));
        console.log('Filtered data saved as filtered_drugs.json');
    });

}).on("error", (err) => {
    console.log("Error: " + err.message);
});

