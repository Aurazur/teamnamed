# teamnamed
Our team name is Teamnamed, and our group members are Jeffrey Cheong, Brian Chong and Cameron Stuart.
The topic we selected is Digital Heritage and Tourism.
Our application is named JoMalaysia, a wordplay of Jom and Malaysia!

### Challenges
The challenges we identified from the chosen topic were:
1. Low Engagement with Cultural Content
2. Difficulty in Encouraging Repeat Visits and Cultural Exploration
3. Lack of Incentives for Tourists to Support Local Economy

### Approaches
The approaches we took to solve these problems are as follows:
1. Gamification through Badge System & QR Check-ins
2. Progressive Badge Tiers
3. Cultural-Driven Tourism Incentives

### Technologies Used
We used Flutter to create this mobile application, pairing with Firebase and the Google Maps API.

### AI Assistance
ChatGPT has assisted us in implementing and integrating the Firebase and Google Maps API, along with some bug fixes and error patching (such as specific dependency versions, Android SDK mismatches or the QR scanner, but failed). ChatGPT has also assisted us in acquiring information such as specific government grants and its scopes, and helping us structure our Firebase properly (using Maps inside of Arrays and so on).

## Getting Started
The first screen you will be met with is the Login screen. Users can either login to existing accounts, or creating new ones through the Register page accessible from the Login page (you must verify your email before logging in). /n
After logging in, you will be greeted with the Home screen. This screen contains a navbar below to access the map (where our partnered landmarks are marked) and Settings (where you can edit your username, and set preferences such as App Language and Notifications [preferences have not been implemented])
The Home screen also contains Nearby Sites, Badges, Local Food Deals, Audio Guides (unimplemented), Multilingual Info (unimplemented) and QR buttons. 
The Nearby Sites button will show you a list of sites nearest to you, with their distances and a short description.
The Badges button will display all the badges, alongside your earned badges, and your completion rates.
The Local Food Deals button will show you the nearby local food places alongside their menus (you also get a discount of 5% on your purchase for showing your QR code!).
The QR button opens up to your personal QR to allow our partnered cashiers to scan for discounts, and you can also access a QR scanner (not working, so replaced with a simulator) which can scan QR codes located in partnered sites to unlock and upgrade badges.
