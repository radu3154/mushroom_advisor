class Location
  # Romanian cities with foraging areas
  # Each region has: lat, lon, name_ro (Romanian), name_en (English)
  TREE = {
    "Romania" => {
      "Alba Iulia" => {
        "trascau" => { lat: 46.32, lon: 23.48, name_en: "Trascau Mountains", name_ro: "Munții Trascău" },
        "secas" => { lat: 46.10, lon: 23.55, name_en: "Secas Forest", name_ro: "Pădurea Secaș" },
        "arieseni" => { lat: 46.45, lon: 22.72, name_en: "Arieseni Forest", name_ro: "Pădurea Arieșeni" },
        "scarita" => { lat: 46.38, lon: 23.42, name_en: "Scarita Belioara", name_ro: "Scărița Belioara" },
        "galzii" => { lat: 46.25, lon: 23.35, name_en: "Valea Galzii Forest", name_ro: "Pădurea Valea Gălzii" }
      },
      "Alexandria" => {
        "vedea" => { lat: 43.98, lon: 25.30, name_en: "Vedea Floodplain", name_ro: "Lunca Vedei" },
        "bujoru" => { lat: 43.92, lon: 25.38, name_en: "Bujoru Forest", name_ro: "Pădurea Bujoru" },
        "teleorman" => { lat: 44.05, lon: 25.22, name_en: "Teleorman Valley", name_ro: "Valea Teleormanului" }
      },
      "Arad" => {
        "ceala" => { lat: 46.20, lon: 21.30, name_en: "Ceala Forest", name_ro: "Pădurea Ceala" },
        "zarand" => { lat: 46.30, lon: 21.85, name_en: "Zarand Mountains", name_ro: "Munții Zarand" },
        "moneasa" => { lat: 46.38, lon: 22.15, name_en: "Moneasa Forest", name_ro: "Pădurea Moneasa" },
        "lipova" => { lat: 46.08, lon: 21.68, name_en: "Lipova Hills", name_ro: "Dealurile Lipovei" },
        "ineu" => { lat: 46.42, lon: 21.82, name_en: "Ineu Forest", name_ro: "Pădurea Ineu" }
      },
      "Bacau" => {
        "margineni" => { lat: 46.60, lon: 26.85, name_en: "Margineni Forest", name_ro: "Pădurea Mărgineanu" },
        "slanic" => { lat: 46.20, lon: 26.42, name_en: "Slanic Moldova Forest", name_ro: "Pădurea Slănic Moldova" },
        "nemira" => { lat: 46.30, lon: 26.50, name_en: "Nemira Mountains", name_ro: "Munții Nemira" },
        "magura" => { lat: 46.28, lon: 26.68, name_en: "Magura Casinului", name_ro: "Măgura Cașinului" },
        "oituz" => { lat: 46.18, lon: 26.58, name_en: "Oituz Valley", name_ro: "Valea Oituzului" }
      },
      "Baia Mare" => {
        "firiza" => { lat: 47.70, lon: 23.50, name_en: "Firiza Forest", name_ro: "Pădurea Firiza" },
        "ignis" => { lat: 47.78, lon: 23.68, name_en: "Ignis Mountains", name_ro: "Munții Igniș" },
        "creasta" => { lat: 47.72, lon: 23.82, name_en: "Creasta Cocosului", name_ro: "Creasta Cocoșului" },
        "gutai" => { lat: 47.75, lon: 23.72, name_en: "Gutai Mountains", name_ro: "Munții Gutâi" },
        "prislop" => { lat: 47.58, lon: 24.82, name_en: "Prislop Pass", name_ro: "Pasul Prislop" },
        "rodna" => { lat: 47.55, lon: 24.62, name_en: "Rodna Mountains", name_ro: "Munții Rodnei" },
        "baiasprie" => { lat: 47.66, lon: 23.68, name_en: "Baia Sprie Forest", name_ro: "Pădurea Baia Sprie" }
      },
      "Bistrita" => {
        "colibita" => { lat: 47.25, lon: 24.48, name_en: "Colibita Forest", name_ro: "Pădurea Colibiței" },
        "bargau" => { lat: 47.30, lon: 24.70, name_en: "Bargau Mountains", name_ro: "Munții Bârgău" },
        "livezile" => { lat: 47.18, lon: 24.35, name_en: "Livezile Forest", name_ro: "Pădurea Livezile" },
        "tihuza" => { lat: 47.35, lon: 24.55, name_en: "Tihuza Forest", name_ro: "Pădurea Tihuța" },
        "budac" => { lat: 47.10, lon: 24.42, name_en: "Budacul de Jos Forest", name_ro: "Pădurea Budacul de Jos" }
      },
      "Botosani" => {
        "stauceni" => { lat: 47.72, lon: 26.68, name_en: "Stauceni Forest", name_ro: "Pădurea Stăuceni" },
        "tudora" => { lat: 47.65, lon: 26.55, name_en: "Tudora Forest", name_ro: "Pădurea Tudora" },
        "vorona" => { lat: 47.62, lon: 26.78, name_en: "Vorona Forest", name_ro: "Pădurea Vorona" }
      },
      "Braila" => {
        "insula" => { lat: 45.30, lon: 27.95, name_en: "Braila Island Forest", name_ro: "Pădurea Insula Brăilei" },
        "lacusarat" => { lat: 45.22, lon: 27.92, name_en: "Lacu Sarat Forest", name_ro: "Pădurea Lacu Sărat" },
        "baldovinesti" => { lat: 45.35, lon: 27.88, name_en: "Baldovinesti Forest", name_ro: "Pădurea Baldovinești" }
      },
      "Brasov" => {
        "poiana" => { lat: 45.59, lon: 25.55, name_en: "Poiana Brasov", name_ro: "Poiana Brașov" },
        "piatramare" => { lat: 45.58, lon: 25.68, name_en: "Piatra Mare", name_ro: "Piatra Mare" },
        "rasnov" => { lat: 45.59, lon: 25.46, name_en: "Rasnov Forest", name_ro: "Pădurea Râșnov" },
        "piatracraiului" => { lat: 45.52, lon: 25.22, name_en: "Piatra Craiului", name_ro: "Piatra Craiului" },
        "zarnesti" => { lat: 45.55, lon: 25.28, name_en: "Zarnesti Gorge", name_ro: "Prăpăstiile Zărneștilor" },
        "postavaru" => { lat: 45.57, lon: 25.58, name_en: "Postavaru Mountains", name_ro: "Muntele Postăvaru" },
        "codlea" => { lat: 45.70, lon: 25.45, name_en: "Codlea Forest", name_ro: "Pădurea Codlea" }
      },
      "București" => {
        "baneasa" => { lat: 44.50, lon: 26.07, name_en: "Baneasa Forest", name_ro: "Pădurea Băneasa" },
        "snagov" => { lat: 44.70, lon: 26.15, name_en: "Snagov Forest", name_ro: "Pădurea Snagov" },
        "cernica" => { lat: 44.40, lon: 26.22, name_en: "Cernica Forest", name_ro: "Pădurea Cernica" },
        "pasarea" => { lat: 44.42, lon: 26.28, name_en: "Pasarea Forest", name_ro: "Pădurea Pasărea" }
      },
      "Buzau" => {
        "bisoca" => { lat: 45.55, lon: 26.70, name_en: "Bisoca Forest", name_ro: "Pădurea Bisoca" },
        "penteleu" => { lat: 45.50, lon: 26.40, name_en: "Penteleu Mountains", name_ro: "Munții Penteleu" },
        "siriu" => { lat: 45.45, lon: 26.08, name_en: "Siriu Forest", name_ro: "Pădurea Siriu" }
      },
      "Calarasi" => {
        "mostistea" => { lat: 44.22, lon: 26.78, name_en: "Mostistea Forest", name_ro: "Pădurea Moștiștea" },
        "oltenita" => { lat: 44.08, lon: 26.63, name_en: "Oltenita Forest", name_ro: "Pădurea Oltenița" },
        "ciornuleasa" => { lat: 44.35, lon: 26.75, name_en: "Ciornuleasa Forest", name_ro: "Pădurea Ciornuleasa" }
      },
      "Cluj-Napoca" => {
        "hoia" => { lat: 46.78, lon: 23.55, name_en: "Hoia Forest", name_ro: "Pădurea Hoia" },
        "faget" => { lat: 46.73, lon: 23.53, name_en: "Faget Forest", name_ro: "Pădurea Făget" },
        "apuseni" => { lat: 46.55, lon: 23.05, name_en: "Apuseni Mountains", name_ro: "Munții Apuseni" },
        "belis" => { lat: 46.40, lon: 23.20, name_en: "Belis-Fantanele Lake", name_ro: "Lacul Beliș-Fântânele" },
        "vladeasa" => { lat: 46.65, lon: 22.78, name_en: "Vladeasa Mountains", name_ro: "Munții Vlădeasa" },
        "turzii" => { lat: 46.57, lon: 23.68, name_en: "Cheile Turzii", name_ro: "Cheile Turzii" },
        "gilau" => { lat: 46.75, lon: 23.38, name_en: "Gilau Forest", name_ro: "Pădurea Gilău" }
      },
      "Constanta" => {
        "hagieni" => { lat: 43.82, lon: 28.55, name_en: "Hagieni Forest", name_ro: "Pădurea Hagieni" },
        "canaraua" => { lat: 44.00, lon: 27.72, name_en: "Canaraua Fetii", name_ro: "Canaraua Fetii" },
        "techirghiol" => { lat: 44.05, lon: 28.58, name_en: "Techirghiol Forest", name_ro: "Pădurea Techirghiol" }
      },
      "Craiova" => {
        "bucovat" => { lat: 44.35, lon: 23.75, name_en: "Bucovat Forest", name_ro: "Pădurea Bucovăț" },
        "romanesti" => { lat: 44.28, lon: 23.80, name_en: "Romanesti Forest", name_ro: "Pădurea Românești" },
        "jiu" => { lat: 44.25, lon: 23.82, name_en: "Jiu Floodplain", name_ro: "Lunca Jiului" }
      },
      "Deva" => {
        "retezat" => { lat: 45.35, lon: 22.85, name_en: "Retezat Mountains", name_ro: "Munții Retezat" },
        "gradistea" => { lat: 45.50, lon: 23.25, name_en: "Gradistea Forest", name_ro: "Pădurea Grădiștea" },
        "poianarusca" => { lat: 45.58, lon: 22.48, name_en: "Poiana Rusca Mountains", name_ro: "Munții Poiana Ruscă" },
        "jiugorge" => { lat: 45.32, lon: 23.38, name_en: "Jiu Gorge", name_ro: "Defileul Jiului" },
        "geoagiu" => { lat: 45.92, lon: 23.18, name_en: "Geoagiu Forest", name_ro: "Pădurea Geoagiu" },
        "hunedoara" => { lat: 45.75, lon: 22.90, name_en: "Hunedoara Forest", name_ro: "Pădurea Hunedoara" }
      },
      "Drobeta-Turnu Severin" => {
        "domogled" => { lat: 44.88, lon: 22.38, name_en: "Domogled Forest", name_ro: "Pădurea Domogled" },
        "cerna" => { lat: 44.95, lon: 22.42, name_en: "Cerna Valley", name_ro: "Valea Cernei" },
        "hinova" => { lat: 44.55, lon: 22.65, name_en: "Hinova Forest", name_ro: "Pădurea Hinova" },
        "mehedinti" => { lat: 44.78, lon: 22.55, name_en: "Mehedinti Plateau", name_ro: "Platoul Mehedinți" }
      },
      "Focsani" => {
        "soveja" => { lat: 45.98, lon: 26.68, name_en: "Soveja Forest", name_ro: "Pădurea Soveja" },
        "milcov" => { lat: 45.72, lon: 27.10, name_en: "Milcov Forest", name_ro: "Pădurea Milcov" },
        "lepsa" => { lat: 45.92, lon: 26.58, name_en: "Lepsa Forest", name_ro: "Pădurea Lepșa" }
      },
      "Galati" => {
        "garboavele" => { lat: 45.38, lon: 28.02, name_en: "Garboavele Forest", name_ro: "Pădurea Gârboavele" },
        "insulabraila" => { lat: 45.42, lon: 28.10, name_en: "Braila Island", name_ro: "Insula Brăilei" },
        "sendreni" => { lat: 45.35, lon: 27.92, name_en: "Sendreni Forest", name_ro: "Pădurea Sendreni" }
      },
      "Giurgiu" => {
        "comana" => { lat: 44.15, lon: 26.12, name_en: "Comana Natural Park", name_ro: "Parcul Natural Comana" },
        "calugareni" => { lat: 44.25, lon: 26.05, name_en: "Calugareni Forest", name_ro: "Pădurea Călugăreni" },
        "bolintin" => { lat: 44.42, lon: 25.78, name_en: "Bolintin Forest", name_ro: "Pădurea Bolintin" }
      },
      "Iasi" => {
        "cetatuia" => { lat: 47.15, lon: 27.55, name_en: "Cetatuia Forest", name_ro: "Pădurea Cetățuia" },
        "repedea" => { lat: 47.12, lon: 27.62, name_en: "Repedea Forest", name_ro: "Pădurea Repedea" },
        "barnova" => { lat: 47.08, lon: 27.60, name_en: "Barnova Forest", name_ro: "Pădurea Bârnova" },
        "ciric" => { lat: 47.18, lon: 27.60, name_en: "Ciric Forest", name_ro: "Pădurea Ciric" },
        "breazu" => { lat: 47.05, lon: 27.55, name_en: "Breazu Forest", name_ro: "Pădurea Breazu" }
      },
      "Miercurea Ciuc" => {
        "harghita" => { lat: 46.35, lon: 25.80, name_en: "Harghita Mountains", name_ro: "Munții Harghita" },
        "jigodin" => { lat: 46.38, lon: 25.82, name_en: "Jigodin Forest", name_ro: "Pădurea Jigodin" },
        "sumuleu" => { lat: 46.37, lon: 25.78, name_en: "Sumuleu Forest", name_ro: "Pădurea Șumuleu" },
        "tusnad" => { lat: 46.28, lon: 25.88, name_en: "Tusnad Forest", name_ro: "Pădurea Tușnad" },
        "racu" => { lat: 46.42, lon: 25.75, name_en: "Racu Forest", name_ro: "Pădurea Racu" }
      },
      "Oradea" => {
        "stanadeval" => { lat: 46.65, lon: 22.55, name_en: "Stana de Vale", name_ro: "Stâna de Vale" },
        "padureacraiului" => { lat: 46.78, lon: 22.48, name_en: "Padurea Craiului", name_ro: "Pădurea Craiului" },
        "betfia" => { lat: 46.92, lon: 22.02, name_en: "Betfia Forest", name_ro: "Pădurea Betfia" },
        "apuseniparc" => { lat: 46.55, lon: 22.72, name_en: "Apuseni Natural Park", name_ro: "Parcul Natural Apuseni" },
        "meziad" => { lat: 46.75, lon: 22.38, name_en: "Meziad Forest", name_ro: "Pădurea Meziad" },
        "vaducrisului" => { lat: 46.95, lon: 22.18, name_en: "Vadu Crisului Forest", name_ro: "Pădurea Vadu Crișului" }
      },
      "Petrosani" => {
        "jiuvalley" => { lat: 45.42, lon: 23.38, name_en: "Jiu Valley Forests", name_ro: "Pădurile Văii Jiului" },
        "parau" => { lat: 45.38, lon: 23.42, name_en: "Parau Forest", name_ro: "Pădurea Pârâu" },
        "vulcan" => { lat: 45.32, lon: 23.25, name_en: "Vulcan Mountains", name_ro: "Munții Vulcan" }
      },
      "Piatra Neamt" => {
        "ceahlau" => { lat: 46.95, lon: 25.95, name_en: "Ceahlau Mountains", name_ro: "Munții Ceahlău" },
        "vanatori" => { lat: 47.15, lon: 26.28, name_en: "Vanatori Neamt Forest", name_ro: "Pădurea Vânători Neamț" },
        "bicaz" => { lat: 46.82, lon: 25.82, name_en: "Bicaz Gorge", name_ro: "Cheile Bicazului" },
        "batca" => { lat: 46.92, lon: 25.98, name_en: "Batca Doamnei", name_ro: "Bâtca Doamnei" },
        "durau" => { lat: 46.88, lon: 25.92, name_en: "Durau Forest", name_ro: "Pădurea Durău" },
        "agapia" => { lat: 47.08, lon: 26.18, name_en: "Agapia Forest", name_ro: "Pădurea Agapia" }
      },
      "Pitesti" => {
        "trivale" => { lat: 44.85, lon: 24.85, name_en: "Trivale Forest", name_ro: "Pădurea Trivale" },
        "golescu" => { lat: 44.88, lon: 24.90, name_en: "Golescu Forest", name_ro: "Pădurea Golescu" },
        "vidraru" => { lat: 45.35, lon: 24.62, name_en: "Vidraru Forest", name_ro: "Pădurea Vidraru" },
        "corbeni" => { lat: 45.25, lon: 24.58, name_en: "Corbeni Forest", name_ro: "Pădurea Corbeni" }
      },
      "Ploiesti" => {
        "bucegi" => { lat: 45.38, lon: 25.45, name_en: "Bucegi Mountains", name_ro: "Munții Bucegi" },
        "prahova" => { lat: 45.30, lon: 25.52, name_en: "Prahova Valley", name_ro: "Valea Prahovei" },
        "breaza" => { lat: 45.18, lon: 25.68, name_en: "Breaza Forest", name_ro: "Pădurea Breaza" },
        "sinaia" => { lat: 45.35, lon: 25.55, name_en: "Sinaia Forest", name_ro: "Pădurea Sinaia" },
        "azuga" => { lat: 45.43, lon: 25.58, name_en: "Azuga Forest", name_ro: "Pădurea Azuga" }
      },
      "Ramnicu Valcea" => {
        "cozia" => { lat: 45.32, lon: 24.35, name_en: "Cozia Mountains", name_ro: "Munții Cozia" },
        "calinesti" => { lat: 45.08, lon: 24.38, name_en: "Calinesti Forest", name_ro: "Pădurea Călinești" },
        "buila" => { lat: 45.22, lon: 24.22, name_en: "Buila Vanturarita", name_ro: "Buila Vânturărița" },
        "lotru" => { lat: 45.38, lon: 24.28, name_en: "Lotru Valley", name_ro: "Valea Lotrului" },
        "horezu" => { lat: 45.15, lon: 24.02, name_en: "Horezu Forest", name_ro: "Pădurea Horezu" }
      },
      "Resita" => {
        "semenic" => { lat: 45.18, lon: 22.05, name_en: "Semenic Mountains", name_ro: "Munții Semenic" },
        "nera" => { lat: 44.95, lon: 21.82, name_en: "Nera Gorge Forest", name_ro: "Cheile Nerei" },
        "caras" => { lat: 45.10, lon: 21.88, name_en: "Caras Valley", name_ro: "Valea Carașului" },
        "garnic" => { lat: 44.98, lon: 21.78, name_en: "Garnic Forest", name_ro: "Pădurea Gârnic" },
        "anina" => { lat: 45.08, lon: 21.85, name_en: "Anina Forest", name_ro: "Pădurea Anina" }
      },
      "Satu Mare" => {
        "livada" => { lat: 47.72, lon: 23.10, name_en: "Livada Forest", name_ro: "Pădurea Livada" },
        "oas" => { lat: 47.88, lon: 23.55, name_en: "Oas Mountains", name_ro: "Munții Oaș" },
        "carei" => { lat: 47.68, lon: 22.48, name_en: "Carei Forest", name_ro: "Pădurea Carei" },
        "negrestioas" => { lat: 47.85, lon: 23.42, name_en: "Negresti-Oas Forest", name_ro: "Pădurea Negrești-Oaș" }
      },
      "Sfantu Gheorghe" => {
        "bodoc" => { lat: 45.82, lon: 25.78, name_en: "Bodoc Mountains", name_ro: "Munții Bodoc" },
        "ojdula" => { lat: 45.90, lon: 26.28, name_en: "Ojdula Forest", name_ro: "Pădurea Ojdula" },
        "covasna" => { lat: 45.85, lon: 26.18, name_en: "Covasna Forest", name_ro: "Pădurea Covasna" },
        "comandau" => { lat: 45.78, lon: 26.32, name_en: "Comandau Forest", name_ro: "Pădurea Comandău" }
      },
      "Sibiu" => {
        "dumbrava" => { lat: 45.78, lon: 24.13, name_en: "Dumbrava Forest", name_ro: "Pădurea Dumbrava Sibiului" },
        "marginimea" => { lat: 45.68, lon: 23.95, name_en: "Marginimea Sibiului", name_ro: "Mărginimea Sibiului" },
        "cindrel" => { lat: 45.62, lon: 24.08, name_en: "Cindrel Mountains", name_ro: "Munții Cindrel" },
        "paltinis" => { lat: 45.65, lon: 24.02, name_en: "Paltinis Forest", name_ro: "Pădurea Păltiniș" },
        "fagaras" => { lat: 45.60, lon: 24.62, name_en: "Fagaras Mountains", name_ro: "Munții Făgăraș" },
        "rasinari" => { lat: 45.72, lon: 24.08, name_en: "Rasinari Forest", name_ro: "Pădurea Rășinari" }
      },
      "Slatina" => {
        "strejestu" => { lat: 44.42, lon: 24.38, name_en: "Strejestu Forest", name_ro: "Pădurea Strejeștu" },
        "olt" => { lat: 44.45, lon: 24.35, name_en: "Olt Floodplain", name_ro: "Lunca Oltului" },
        "stoenesti" => { lat: 44.32, lon: 24.28, name_en: "Stoenesti Forest", name_ro: "Pădurea Stoenești" }
      },
      "Slobozia" => {
        "amara" => { lat: 44.62, lon: 27.32, name_en: "Amara Forest", name_ro: "Pădurea Amara" },
        "balta" => { lat: 44.58, lon: 27.35, name_en: "Balta Ialomitei", name_ro: "Balta Ialomiței" },
        "fetesti" => { lat: 44.38, lon: 27.82, name_en: "Fetesti Forest", name_ro: "Pădurea Fetești" }
      },
      "Suceava" => {
        "rarau" => { lat: 47.45, lon: 25.55, name_en: "Rarau Mountains", name_ro: "Munții Rarău" },
        "calimani" => { lat: 47.10, lon: 25.23, name_en: "Calimani Forest", name_ro: "Pădurea Călimani" },
        "marginea" => { lat: 47.82, lon: 25.82, name_en: "Marginea Forest", name_ro: "Pădurea Marginea" },
        "vatramoldovei" => { lat: 47.65, lon: 25.72, name_en: "Vatra Moldovei Forest", name_ro: "Pădurea Vatra Moldoviței" },
        "campulung" => { lat: 47.52, lon: 25.55, name_en: "Campulung Forest", name_ro: "Pădurea Câmpulung Moldovenesc" },
        "gurahumorului" => { lat: 47.55, lon: 25.88, name_en: "Gura Humorului Forest", name_ro: "Pădurea Gura Humorului" },
        "frasin" => { lat: 47.58, lon: 25.78, name_en: "Frasin Forest", name_ro: "Pădurea Frasin" }
      },
      "Targoviste" => {
        "moreni" => { lat: 44.98, lon: 25.65, name_en: "Moreni Forest", name_ro: "Pădurea Moreni" },
        "iezer" => { lat: 45.42, lon: 25.15, name_en: "Iezer Mountains", name_ro: "Munții Iezer" },
        "teis" => { lat: 44.95, lon: 25.42, name_en: "Teis Forest", name_ro: "Pădurea Teiș" }
      },
      "Targu Jiu" => {
        "tismana" => { lat: 45.05, lon: 22.95, name_en: "Tismana Forest", name_ro: "Pădurea Tismana" },
        "arcani" => { lat: 45.10, lon: 23.18, name_en: "Arcani Forest", name_ro: "Pădurea Arcani" },
        "pestisani" => { lat: 45.08, lon: 23.35, name_en: "Pestisani Forest", name_ro: "Pădurea Peștișani" },
        "runcu" => { lat: 45.12, lon: 23.12, name_en: "Runcu Gorge Forest", name_ro: "Cheile Runcului" }
      },
      "Targu Mures" => {
        "cornesti" => { lat: 46.55, lon: 24.53, name_en: "Platoul Cornesti", name_ro: "Platoul Cornești" },
        "gurghiu" => { lat: 46.75, lon: 25.00, name_en: "Gurghiu Mountains", name_ro: "Munții Gurghiu" },
        "sovata" => { lat: 46.60, lon: 25.07, name_en: "Sovata Forest", name_ro: "Pădurea Sovata" },
        "mures" => { lat: 46.68, lon: 24.88, name_en: "Upper Mures Valley", name_ro: "Valea Superioară a Mureșului" },
        "calimanimures" => { lat: 47.05, lon: 25.25, name_en: "Calimani Mountains", name_ro: "Munții Călimani" },
        "bucin" => { lat: 46.62, lon: 25.18, name_en: "Pasul Bucin Forest", name_ro: "Pădurea Pasul Bucin" }
      },
      "Timisoara" => {
        "greenforest" => { lat: 45.78, lon: 21.20, name_en: "Green Forest", name_ro: "Pădurea Verde" },
        "padureaverde" => { lat: 45.77, lon: 21.18, name_en: "Padurea Verde Park", name_ro: "Parcul Pădurea Verde" },
        "lugoj" => { lat: 45.69, lon: 21.90, name_en: "Lugoj Hills", name_ro: "Dealurile Lugojului" },
        "faget" => { lat: 45.85, lon: 21.82, name_en: "Faget Hills", name_ro: "Dealurile Făgetului" },
        "giroc" => { lat: 45.72, lon: 21.22, name_en: "Giroc Forest", name_ro: "Pădurea Giroc" }
      },
      "Tulcea" => {
        "macin" => { lat: 45.25, lon: 28.35, name_en: "Macin Mountains", name_ro: "Munții Măcin" },
        "babadag" => { lat: 44.88, lon: 28.70, name_en: "Babadag Forest", name_ro: "Pădurea Babadag" },
        "letea" => { lat: 45.30, lon: 29.52, name_en: "Letea Forest", name_ro: "Pădurea Letea" },
        "caraorman" => { lat: 44.90, lon: 29.35, name_en: "Caraorman Forest", name_ro: "Pădurea Caraorman" }
      },
      "Vaslui" => {
        "codresti" => { lat: 46.58, lon: 27.68, name_en: "Codresti Forest", name_ro: "Pădurea Codrești" },
        "moara" => { lat: 46.62, lon: 27.72, name_en: "Moara Domneasca", name_ro: "Moara Domnească" },
        "rebricea" => { lat: 46.70, lon: 27.58, name_en: "Rebricea Forest", name_ro: "Pădurea Rebricea" }
      },
      "Zalau" => {
        "meses" => { lat: 47.15, lon: 23.05, name_en: "Meses Mountains", name_ro: "Munții Meseș" },
        "jibou" => { lat: 47.25, lon: 23.25, name_en: "Jibou Forest", name_ro: "Pădurea Jibou" },
        "crasna" => { lat: 47.18, lon: 22.88, name_en: "Crasna Valley", name_ro: "Valea Crasnei" }
      }
    }
  }.freeze

  def self.tree
    TREE
  end

  # Returns { country:, city:, region:, lat:, lon:, name: } or nil
  def self.find(country, city, region)
    coords = TREE.dig(country, city, region)
    return nil unless coords

    {
      country: country,
      city: city,
      region: region,
      lat: coords[:lat],
      lon: coords[:lon],
      name: "#{coords[:name_en]}, #{city}"
    }
  end

  # JSON structure for the cascading JS dropdown, with both language names
  def self.to_json_tree
    result = {}
    TREE.each do |country, cities|
      result[country] = {}
      cities.each do |city, regions|
        result[country][city] = {}
        regions.each do |key, data|
          result[country][city][key] = {
            en: data[:name_en],
            ro: data[:name_ro]
          }
        end
      end
    end
    result.to_json
  end
end
