// const fs = require('fs');
// const https = require('https');

// // Drug names you want to search for (can add more)
// const drugs = ['aspirin', 'ibuprofen', 'amoxicillin']; // Example drug names

// // Function to get RxCUI for a drug name
// function getRxCUI(drugName) {
//     const url = `https://rxnav.nlm.nih.gov/REST/rxcui.json?name=${encodeURIComponent(drugName)}`;
//     return new Promise((resolve, reject) => {
//         https.get(url, (resp) => {
//             let data = '';
//             resp.on('data', (chunk) => { data += chunk; });
//             resp.on('end', () => {
//                 const jsonData = JSON.parse(data);
//                 if (jsonData.idGroup && jsonData.idGroup.rxnormId) {
//                     resolve(jsonData.idGroup.rxnormId[0]);
//                 } else {
//                     resolve(null);
//                 }
//             });
//         }).on('error', (err) => {
//             reject(err.message);
//         });
//     });
// }

// // Function to get drug info based on RxCUI
// function getDrugInfo(rxcui) {
//     const url = `https://rxnav.nlm.nih.gov/REST/ndcstatus.json?rxcui=${rxcui}`;
//     return new Promise((resolve, reject) => {
//         https.get(url, (resp) => {
//             let data = '';
//             resp.on('data', (chunk) => { data += chunk; });
//             resp.on('end', () => {
//                 resolve(JSON.parse(data));
//             });
//         }).on('error', (err) => {
//             reject(err.message);
//         });
//     });
// }

// // Main function to fetch and save drug data
// async function fetchDrugData() {
//     const drugData = [];

//     for (const drug of drugs) {
//         try {
//             const rxcui = await getRxCUI(drug);
//             if (rxcui) {
//                 const info = await getDrugInfo(rxcui);
//                 const drugInfo = {
//                     name: drug,
//                     rxcui: rxcui,
//                     ingredients: info.supplementary ? info.supplementary.ingredient : 'N/A',
//                     warnings: 'N/A', // RxNorm doesn't provide warnings directly, you may have to get this from another source
//                     image_url: 'N/A'  // RxNorm doesn't directly provide pill images, this could be sourced elsewhere
//                 };
//                 drugData.push(drugInfo);
//             }
//         } catch (error) {
//             console.log(`Error fetching data for ${drug}:`, error);
//         }
//     }

//     // Save data to a JSON file
//     fs.writeFileSync('rxnorm_drugs.json', JSON.stringify(drugData, null, 2));
//     console.log('Drug data saved as rxnorm_drugs.json');
// }

// // Run the function to fetch data
// fetchDrugData();
const fs = require('fs');
const https = require('https');

// Drug names you want to search for (can add more)
const drugs = ['aspirin', 'ibuprofen', 'amoxicillin']; // Example drug names

// Function to get RxCUI for a drug name
function getRxCUI(drugName) {
    const url = `https://rxnav.nlm.nih.gov/REST/rxcui.json?name=${encodeURIComponent(drugName)}`;
    return new Promise((resolve, reject) => {
        https.get(url, (resp) => {
            let data = '';
            resp.on('data', (chunk) => { data += chunk; });
            resp.on('end', () => {
                try {
                    const jsonData = JSON.parse(data);
                    if (jsonData.idGroup && jsonData.idGroup.rxnormId) {
                        resolve(jsonData.idGroup.rxnormId[0]);
                    } else {
                        resolve(null);
                    }
                } catch (error) {
                    reject(new Error('Failed to parse JSON response'));
                }
            });
        }).on('error', (err) => {
            reject(new Error('Request failed: ' + err.message));
        });
    });
}

// Function to get RxCUIs for all drugs
async function getAllRxCUIs() {
    const results = {};
    for (const drug of drugs) {
        try {
            const rxCUI = await getRxCUI(drug);
            results[drug] = rxCUI;
        } catch (error) {
            console.error(`Error fetching RxCUI for ${drug}: ${error.message}`);
            results[drug] = null;
        }
    }
    return results;
}

// Main function to fetch and save RxCUIs
async function main() {
    try {
        const rxCUIs = await getAllRxCUIs();
        fs.writeFileSync('drugs.json', JSON.stringify(rxCUIs, null, 2));
        console.log('File saved!');
    } catch (error) {
        console.error('Error:', error.message);
    }
}

main();