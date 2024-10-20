Medisense APP

Medisense is an application that allows patients to book appointments with doctors and order medications online from pharmacies. It simplifies healthcare access by providing a unified platform for patients to manage their healthcare needs.
Features

    Doctor Appointments: Patients can search for doctors by location, and availability. The app allows users to book, reschedule, or cancel appointments easily.
    Pharmacy Orders: Patients can browse pharmacies and order medications online. The app provides prescription uploading and payment options for a seamless user experience.
    User Profiles: Each patient has a personal profile where they can manage their appointments, prescriptions, and order history.
    Notifications: Patients receive reminders for upcoming appointments and updates on their pharmacy orders.
    Secure Payment: Integration with secure payment gateways for easy online payments for both appointments and pharmacy orders.

Tech Stack

    Backend: [Ballerina]
    Frontend: [Flutter]
    Database: [Mysql]
    APIs:
        [There is no APIs]
    Payment Integration: []


Installation
Prerequisites

    Ballerina: Install Ballerina (https://ballerina.io/)
    Flutter: Install Flutter (https://flutter.dev/docs/get-started/install)
    Database: Set up the database (e.g., MySQL)

Backend Setup (Ballerina)

    Clone the repository:
    
    bash
git clone https://github.com/yourusername/medisense.git
cd medisense/backend

Install dependencies:

bash

ballerina pull

Configure the database settings in Config.toml (update database URL, username, and password).

Run the backend server:

bash

    ballerina run main.bal

Frontend Setup (Flutter)

    Navigate to the frontend directory:

    bash

cd medisense/frontend

Install dependencies:

bash

flutter pub get

Run the frontend application:

bash

    flutter run

Usage

    Register or log in as a patient.
    Browse doctors and schedule appointments.
    Order medications online from the pharmacy.
    View appointment details, track pharmacy orders, and manage your profile.
