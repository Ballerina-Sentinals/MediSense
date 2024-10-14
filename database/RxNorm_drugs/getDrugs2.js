const fs = require('fs');
const https = require('https');

// Function to get all drugs from the database
function getAllDrugs() {
    const url = 'https://rxnav.nlm.nih.gov/REST/allconcepts.json?tty=IN'; // Example endpoint
    return new Promise((resolve, reject) => {
        https.get(url, (resp) => {
            let data = '';
            resp.on('data', (chunk) => { data += chunk; });
            resp.on('end', () => {
                try {
                    const jsonData = JSON.parse(data);
                    resolve(jsonData);
                } catch (error) {
                    reject(new Error('Failed to parse JSON response'));
                }
            });
        }).on('error', (err) => {
            reject(new Error('Request failed: ' + err.message));
        });
    });
}

// Main function to fetch and save all drugs
async function main() {
    try {
        const drugsData = await getAllDrugs();
        const drugs = drugsData.minConceptGroup.minConcept.map(drug => ({
            name: drug.name,
            rxcui: drug.rxcui
        }));
        fs.writeFileSync('drugs.json', JSON.stringify(drugs, null, 2));
        console.log('File saved!');
    } catch (error) {
        console.error('Error:', error.message);
    }
}

main();