class Species
  CATALOG = {
    "morel" => {
      name: "Morel",
      name_ro: "Zbârciog",
      latin: "Morchella esculenta",
      description: "The honeycomb-capped treasure of spring forests. Morels appear after warm rains in deciduous woods, especially near ash, elm, and old apple orchards.",
      description_ro: "Comoara cu căciulă în fagure a pădurilor de primăvară. Zbârciogii apar după ploi calde în păduri de foioase, mai ales lângă frăsini, ulmi și livezi vechi de meri.",
      season_months: [3, 4, 5],
      temp_range: { ideal_min: 8, ideal_max: 15, abs_min: 4, abs_max: 22 },
      rain_range: { ideal_min: 10, ideal_max: 35, abs_min: 3, abs_max: 55 },
      delay_days: { ideal_min: 3, ideal_max: 5, abs_min: 1, abs_max: 10 },
      # Morels respond to sustained soil warmth (~20-day accumulation).
      # 7-day air temp average is the best proxy we have for soil temperature.
      temp_window: 7,
      # Terrain scoring: ideal types get max, partial gets half, bad gets 0
      preferred_terrain: { ideal: ["deciduous", "grassland", "orchard"], partial: ["mixed", "scrubland", "farmland", "park", "wetland"], bad: ["coniferous", "water"] },
      tips: [
        "#{IconHelper.icon(:apple)} Old apple and pear orchards are prime spots",
        "#{IconHelper.icon(:tree_deciduous)} Look near ash, elm, and tulip poplar trees",
        "#{IconHelper.icon(:sun)} South-facing slopes with morning sun and sandy loam",
        "#{IconHelper.icon(:rain_heavy)} Check 3-5 days after a good spring rain",
        "#{IconHelper.icon(:blossom)} Look when lilacs bloom and soil hits 10°C",
        "#{IconHelper.icon(:fire)} Burn sites and disturbed soil from last year are gold",
        "#{IconHelper.icon(:sunrise)} Early morning light makes them easier to spot"
      ],
      tips_ro: [
        "#{IconHelper.icon(:apple)} Livezile vechi de meri și peri sunt locuri ideale",
        "#{IconHelper.icon(:tree_deciduous)} Caută lângă frăsini, ulmi și plopi",
        "#{IconHelper.icon(:sun)} Versanți sudici cu soare dimineața și sol nisipos",
        "#{IconHelper.icon(:rain_heavy)} Verifică la 3-5 zile după o ploaie bună de primăvară",
        "#{IconHelper.icon(:blossom)} Caută când înfloresc liliacul și solul atinge 10°C",
        "#{IconHelper.icon(:fire)} Zonele arse și solul deranjat din anul trecut sunt de aur",
        "#{IconHelper.icon(:sunrise)} Lumina dimineții le face mai ușor de observat"
      ],
      color: "#8B6914",
      gradient_from: "#a67c28",
      gradient_to: "#d4a843",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Morchella_esculenta_var._rotunda_01.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Morchella-esculenta-anglars.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Morchella_esculenta_-_DE_-_TH_-_2013-05-01_-_02.JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="morel-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#d6e8c0"/>
              <stop offset="60%" stop-color="#b8c9a0"/>
              <stop offset="100%" stop-color="#8b7355"/>
            </linearGradient>
            <linearGradient id="morel-cap" x1="0.3" y1="0" x2="0.7" y2="1">
              <stop offset="0%" stop-color="#c4a545"/>
              <stop offset="40%" stop-color="#9e7b20"/>
              <stop offset="100%" stop-color="#6b5010"/>
            </linearGradient>
            <linearGradient id="morel-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#e8dcc0"/>
              <stop offset="30%" stop-color="#f5ecd8"/>
              <stop offset="70%" stop-color="#f5ecd8"/>
              <stop offset="100%" stop-color="#ddd0b0"/>
            </linearGradient>
            <radialGradient id="morel-pit" cx="0.4" cy="0.35" r="0.5">
              <stop offset="0%" stop-color="#5a4010" stop-opacity="0.7"/>
              <stop offset="100%" stop-color="#5a4010" stop-opacity="0"/>
            </radialGradient>
            <clipPath id="morel-cap-clip">
              <path d="M200 38 Q165 42 155 85 Q148 120 158 155 Q165 175 180 185 Q190 190 200 191 Q210 190 220 185 Q235 175 242 155 Q252 120 245 85 Q235 42 200 38 Z"/>
            </clipPath>
            <filter id="morel-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#morel-bg)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="282" rx="220" ry="30" fill="#6b5a3a" opacity="0.25"/>
          <ellipse cx="200" cy="278" rx="200" ry="18" fill="#7a6a48" opacity="0.2"/>
          <!-- Fallen leaves -->
          <ellipse cx="85" cy="272" rx="28" ry="7" fill="#8a7a3a" opacity="0.35" transform="rotate(-20 85 272)"/>
          <ellipse cx="92" cy="268" rx="22" ry="5" fill="#9a8a4a" opacity="0.25" transform="rotate(-10 92 268)"/>
          <ellipse cx="310" cy="270" rx="30" ry="6" fill="#7a6a30" opacity="0.3" transform="rotate(15 310 270)"/>
          <ellipse cx="320" cy="266" rx="20" ry="5" fill="#8a7a40" opacity="0.2" transform="rotate(25 320 266)"/>
          <!-- Tiny twigs -->
          <line x1="60" y1="275" x2="110" y2="270" stroke="#6b5a3a" stroke-width="1.2" opacity="0.3"/>
          <line x1="280" y1="273" x2="340" y2="268" stroke="#6b5a3a" stroke-width="1" opacity="0.25"/>
          <!-- Main morel with shadow -->
          <g filter="url(#morel-shadow)">
            <!-- Stem - slightly irregular, not a perfect rectangle -->
            <path d="M183 272 Q179 255 178 230 Q178 210 181 195 Q183 188 188 185 L212 185 Q217 188 219 195 Q222 210 222 230 Q221 255 217 272 Z" fill="url(#morel-stem)"/>
            <!-- Stem texture lines -->
            <path d="M189 270 Q188 250 189 220 Q189 200 190 190" stroke="#c8b890" stroke-width="0.6" fill="none" opacity="0.4"/>
            <path d="M196 272 Q195 248 196 218 Q196 198 197 188" stroke="#c8b890" stroke-width="0.5" fill="none" opacity="0.3"/>
            <path d="M204 272 Q205 248 204 218 Q204 198 203 188" stroke="#c8b890" stroke-width="0.5" fill="none" opacity="0.3"/>
            <path d="M211 270 Q212 250 211 220 Q211 200 210 190" stroke="#c8b890" stroke-width="0.6" fill="none" opacity="0.4"/>
            <!-- Stem-to-cap skirt -->
            <ellipse cx="200" cy="185" rx="22" ry="5" fill="#e0d4b8" opacity="0.6"/>
            <!-- Cap - conical, irregular morel shape -->
            <path d="M200 38 Q165 42 155 85 Q148 120 158 155 Q165 175 180 185 Q190 190 200 191 Q210 190 220 185 Q235 175 242 155 Q252 120 245 85 Q235 42 200 38 Z" fill="url(#morel-cap)"/>
            <!-- Everything inside cap clipped to cap outline -->
            <g clip-path="url(#morel-cap-clip)">
              <!-- Cap highlight (left side light) -->
              <path d="M200 42 Q172 48 163 85 Q158 110 164 145 Q168 162 178 175 Q185 168 185 145 Q182 110 185 80 Q190 52 200 42 Z" fill="#c4a545" opacity="0.35"/>
              <!-- Row 1 (top, narrow) -->
              <path d="M191 48 L197 44 L204 48 L203 56 L196 59 L190 55 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <!-- Row 2 -->
              <path d="M176 62 L184 58 L191 62 L190 71 L183 74 L175 70 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M196 60 L204 56 L212 60 L211 69 L204 72 L195 68 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M216 63 L223 59 L229 63 L228 71 L222 74 L215 70 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.1" opacity="0.6"/>
              <!-- Row 3 -->
              <path d="M163 80 L171 76 L178 80 L177 89 L170 92 L162 88 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.65"/>
              <path d="M183 78 L191 74 L199 78 L198 87 L191 90 L182 86 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M204 76 L212 72 L220 76 L219 85 L212 88 L203 84 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M225 79 L232 75 L238 79 L237 87 L231 90 L224 86 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.1" opacity="0.55"/>
              <!-- Row 4 -->
              <path d="M157 99 L165 95 L173 99 L172 108 L165 111 L156 107 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.6"/>
              <path d="M178 97 L186 93 L194 97 L193 106 L186 109 L177 105 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M199 95 L207 91 L215 95 L214 104 L207 107 L198 103 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M220 97 L228 93 L235 97 L234 106 L227 109 L219 105 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.1" opacity="0.55"/>
              <path d="M238 100 L244 97 L248 101 L247 108 L242 110 L237 107 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.45"/>
              <!-- Row 5 -->
              <path d="M155 118 L163 114 L171 118 L170 127 L163 130 L154 126 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.6"/>
              <path d="M176 116 L184 112 L192 116 L191 125 L184 128 L175 124 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M197 114 L205 110 L213 114 L212 123 L205 126 L196 122 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.7"/>
              <path d="M218 116 L226 112 L233 116 L232 125 L225 128 L217 124 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.1" opacity="0.55"/>
              <path d="M236 119 L242 116 L247 120 L246 127 L241 129 L235 126 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.45"/>
              <!-- Row 6 -->
              <path d="M157 137 L165 133 L173 137 L172 146 L165 149 L156 145 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.6"/>
              <path d="M178 135 L186 131 L194 135 L193 144 L186 147 L177 143 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.65"/>
              <path d="M199 133 L207 129 L215 133 L214 142 L207 145 L198 141 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.65"/>
              <path d="M220 135 L228 131 L234 135 L233 143 L227 146 L219 142 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.5"/>
              <!-- Row 7 -->
              <path d="M162 155 L170 151 L177 155 L176 163 L169 166 L161 162 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.1" opacity="0.55"/>
              <path d="M182 153 L190 149 L197 153 L196 161 L189 164 L181 160 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.2" opacity="0.6"/>
              <path d="M202 151 L210 147 L217 151 L216 159 L209 162 L201 158 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1.1" opacity="0.55"/>
              <path d="M222 154 L228 150 L234 154 L233 161 L227 163 L221 160 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.45"/>
              <!-- Row 8 (bottom, narrowing) -->
              <path d="M170 171 L177 167 L184 171 L183 178 L177 181 L169 177 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.5"/>
              <path d="M189 169 L196 165 L203 169 L202 176 L196 179 L188 175 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.5"/>
              <path d="M208 171 L215 167 L221 171 L220 178 L214 181 L207 177 Z" fill="url(#morel-pit)" stroke="#5a4010" stroke-width="1" opacity="0.45"/>
              <!-- Ridge highlights -->
              <path d="M191 62 L196 60 L195 68" stroke="#c4a545" stroke-width="0.5" fill="none" opacity="0.4"/>
              <path d="M178 80 L183 78 L182 86" stroke="#c4a545" stroke-width="0.5" fill="none" opacity="0.35"/>
              <path d="M199 95 L204 97 L198 103" stroke="#c4a545" stroke-width="0.5" fill="none" opacity="0.35"/>
              <path d="M192 116 L197 114 L196 122" stroke="#c4a545" stroke-width="0.5" fill="none" opacity="0.3"/>
              <path d="M194 135 L199 133 L198 141" stroke="#c4a545" stroke-width="0.5" fill="none" opacity="0.3"/>
            </g>
          </g>
          <!-- Small grass tufts -->
          <path d="M140 275 Q142 260 138 250" stroke="#6b8a4a" stroke-width="1.5" fill="none" opacity="0.4"/>
          <path d="M144 275 Q145 262 148 252" stroke="#7a9a5a" stroke-width="1.2" fill="none" opacity="0.35"/>
          <path d="M255 274 Q253 262 257 253" stroke="#6b8a4a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M259 274 Q261 263 258 254" stroke="#7a9a5a" stroke-width="1.1" fill="none" opacity="0.3"/>
        </svg>
      SVG
    },
    "boletus" => {
      name: "Boletus (Porcini)",
      name_ro: "Hrib (Mănătarcă)",
      latin: "Boletus edulis",
      description: "The king of edible mushrooms. Porcini thrive in mixed forests under oak, spruce, and pine after summer and autumn rains.",
      description_ro: "Regele ciupercilor comestibile. Hribii prosperă în păduri mixte sub stejari, molizi și pini, după ploile de vară și toamnă.",
      season_months: [6, 7, 8, 9, 10],
      temp_range: { ideal_min: 13, ideal_max: 21, abs_min: 8, abs_max: 28 },
      rain_range: { ideal_min: 15, ideal_max: 45, abs_min: 5, abs_max: 70 },
      delay_days: { ideal_min: 5, ideal_max: 10, abs_min: 2, abs_max: 14 },
      # Boletus cares more about moisture than temperature.
      # 5-day average captures post-rain cooling events that trigger fruiting.
      temp_window: 5,
      # Boletus thrives in mixed forests, fine in both pure types, less in grassland
      preferred_terrain: { ideal: ["mixed", "deciduous", "coniferous"], partial: ["grassland", "orchard", "scrubland", "park", "wetland"], bad: ["farmland", "water"] },
      tips: [
        "#{IconHelper.icon(:mixed_forest)} Mixed forests — under oak, spruce, pine, birch",
        "#{IconHelper.icon(:moss)} Mossy forest floors with dappled shade",
        "#{IconHelper.icon(:clearing)} Forest clearings and well-drained slopes with leaf litter",
        "#{IconHelper.icon(:storm)} Best 5-10 days after sustained summer rain",
        "#{IconHelper.icon(:fog)} Warm humid mornings are ideal hunting time",
        "#{IconHelper.icon(:map_pin)} Return to known spots — porcini are loyal"
      ],
      tips_ro: [
        "#{IconHelper.icon(:mixed_forest)} Păduri mixte — sub stejari, molizi, pini, mesteceni",
        "#{IconHelper.icon(:moss)} Podeaua pădurii cu mușchi și umbră",
        "#{IconHelper.icon(:clearing)} Poieni și versanți cu drenaj bun și frunze căzute",
        "#{IconHelper.icon(:storm)} Cel mai bine la 5-10 zile după ploaie de vară",
        "#{IconHelper.icon(:fog)} Diminețile calde și umede sunt ideale",
        "#{IconHelper.icon(:map_pin)} Revino la locurile cunoscute — hribii sunt fideli"
      ],
      color: "#8B4513",
      gradient_from: "#6b3410",
      gradient_to: "#a0522d",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Boletus_edulis_2_2008.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Gemeine_Steinpilz_(Boletus_edulis).JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Boletus_edulis_(5).jpg?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="boletus-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#b8cca0"/>
              <stop offset="50%" stop-color="#9aad80"/>
              <stop offset="100%" stop-color="#6b5a3a"/>
            </linearGradient>
            <linearGradient id="boletus-cap" x1="0.2" y1="0" x2="0.8" y2="1">
              <stop offset="0%" stop-color="#7a4a20"/>
              <stop offset="35%" stop-color="#5c2d0e"/>
              <stop offset="100%" stop-color="#3a1a05"/>
            </linearGradient>
            <radialGradient id="boletus-cap-shine" cx="0.35" cy="0.3" r="0.5">
              <stop offset="0%" stop-color="#9a6a35" stop-opacity="0.5"/>
              <stop offset="100%" stop-color="#5c2d0e" stop-opacity="0"/>
            </radialGradient>
            <linearGradient id="boletus-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#d8ccb0"/>
              <stop offset="20%" stop-color="#f0e8d4"/>
              <stop offset="50%" stop-color="#f5eedc"/>
              <stop offset="80%" stop-color="#ede0c8"/>
              <stop offset="100%" stop-color="#d0c0a0"/>
            </linearGradient>
            <linearGradient id="boletus-pores" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#d8c878"/>
              <stop offset="100%" stop-color="#c8b858"/>
            </linearGradient>
            <filter id="boletus-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="5"/>
              <feOffset dx="4" dy="6"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#boletus-bg)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="282" rx="220" ry="28" fill="#5a4a30" opacity="0.25"/>
          <ellipse cx="200" cy="278" rx="200" ry="18" fill="#6b5a3a" opacity="0.2"/>
          <!-- Scattered pine needles -->
          <g opacity="0.3" stroke="#7a6840" fill="none" stroke-width="0.8">
            <line x1="60" y1="274" x2="95" y2="270"/>
            <line x1="65" y1="276" x2="98" y2="273"/>
            <line x1="300" y1="272" x2="345" y2="268"/>
            <line x1="305" y1="274" x2="342" y2="271"/>
            <line x1="155" y1="278" x2="175" y2="275"/>
            <line x1="230" y1="277" x2="252" y2="273"/>
          </g>
          <!-- Fallen leaf -->
          <path d="M90 270 Q100 262 110 268 Q105 258 95 260 Q88 264 90 270 Z" fill="#8a7a30" opacity="0.3"/>
          <path d="M320 268 Q330 260 342 264 Q336 255 326 256 Q318 260 320 268 Z" fill="#7a6a28" opacity="0.25"/>
          <!-- Moss patches -->
          <g opacity="0.3">
            <circle cx="75" cy="272" r="8" fill="#5a8a3a"/>
            <circle cx="85" cy="269" r="5" fill="#6a9a4a"/>
            <circle cx="68" cy="274" r="4" fill="#4a7a2a"/>
            <circle cx="335" cy="270" r="7" fill="#5a8a3a"/>
            <circle cx="345" cy="267" r="5" fill="#6a9a4a"/>
            <circle cx="350" cy="272" r="4" fill="#4a7a2a"/>
          </g>
          <!-- Main boletus with shadow -->
          <g filter="url(#boletus-shadow)">
            <!-- Stem - thick, bulbous, club-shaped (wider at base) -->
            <path d="M178 276 Q170 260 168 235 Q166 210 172 195 Q176 188 184 184 L216 184 Q224 188 228 195 Q234 210 232 235 Q230 260 222 276 Z" fill="url(#boletus-stem)"/>
            <!-- Stem reticulation pattern (net-like) on upper portion -->
            <g stroke="#b8a878" fill="none" stroke-width="0.6" opacity="0.35">
              <path d="M182 190 Q190 195 198 190 Q206 195 214 190"/>
              <path d="M180 198 Q188 203 196 198 Q204 203 212 198 Q218 202 220 198"/>
              <path d="M178 206 Q186 211 194 206 Q202 211 210 206 Q216 210 222 206"/>
              <path d="M176 214 Q184 219 192 214 Q200 219 208 214 Q214 218 224 214"/>
              <path d="M190 190 L188 206" /><path d="M198 190 L196 206" /><path d="M206 190 L204 206" /><path d="M214 190 L212 206" />
              <path d="M186 198 L184 214" /><path d="M194 198 L192 214" /><path d="M202 198 L200 214" /><path d="M210 198 L208 214" />
            </g>
            <!-- Stem left shadow -->
            <path d="M178 276 Q170 260 168 235 Q166 210 172 195 Q176 188 184 184 L190 184 Q183 190 180 200 Q174 215 175 240 Q176 260 182 276 Z" fill="#b0a080" opacity="0.25"/>
            <!-- Pore surface (yellow-green underside of cap) -->
            <ellipse cx="200" cy="180" rx="85" ry="10" fill="url(#boletus-pores)"/>
            <!-- Pore texture dots -->
            <g fill="#b0a040" opacity="0.3">
              <circle cx="150" cy="180" r="1"/><circle cx="158" cy="179" r="1"/><circle cx="166" cy="180" r="1"/>
              <circle cx="174" cy="179" r="1"/><circle cx="182" cy="180" r="1"/><circle cx="190" cy="179" r="1"/>
              <circle cx="198" cy="180" r="1"/><circle cx="206" cy="179" r="1"/><circle cx="214" cy="180" r="1"/>
              <circle cx="222" cy="179" r="1"/><circle cx="230" cy="180" r="1"/><circle cx="238" cy="179" r="1"/>
              <circle cx="246" cy="180" r="1"/>
            </g>
            <!-- Cap - broad, convex dome -->
            <path d="M108 175 Q110 145 135 120 Q160 100 200 95 Q240 100 265 120 Q290 145 292 175 Z" fill="url(#boletus-cap)"/>
            <!-- Cap glossy shine -->
            <path d="M140 120 Q160 105 200 100 Q215 100 230 105 Q210 100 190 108 Q165 118 150 135 Q142 145 140 155 Z" fill="url(#boletus-cap-shine)"/>
            <!-- Cap edge highlight -->
            <path d="M108 175 Q110 148 130 128" stroke="#9a6a35" stroke-width="0.8" fill="none" opacity="0.3"/>
            <!-- Cap surface subtle variation -->
            <path d="M155 115 Q180 108 200 106 Q225 108 248 118" stroke="#4a2008" stroke-width="0.4" fill="none" opacity="0.15"/>
            <path d="M135 135 Q170 122 200 120 Q235 122 268 138" stroke="#4a2008" stroke-width="0.3" fill="none" opacity="0.1"/>
            <!-- Cap right shadow -->
            <path d="M260 125 Q280 140 288 165 Q290 172 292 175 L270 175 Q268 160 258 145 Q250 132 260 125 Z" fill="#2a1005" opacity="0.2"/>
          </g>
          <!-- Small grass tufts -->
          <path d="M142 276 Q144 264 140 255" stroke="#5a8a3a" stroke-width="1.4" fill="none" opacity="0.4"/>
          <path d="M146 276 Q147 266 150 256" stroke="#6a9a4a" stroke-width="1.1" fill="none" opacity="0.35"/>
          <path d="M250 275 Q248 265 252 256" stroke="#5a8a3a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M254 276 Q256 266 253 257" stroke="#6a9a4a" stroke-width="1" fill="none" opacity="0.3"/>
          <!-- Tiny fern frond -->
          <g opacity="0.25" transform="translate(48, 250) scale(0.6)">
            <path d="M0 40 Q10 30 20 20 Q30 10 40 0" stroke="#5a8a3a" stroke-width="1.5" fill="none"/>
            <path d="M8 34 Q4 28 0 30" stroke="#5a8a3a" stroke-width="0.8" fill="none"/>
            <path d="M14 28 Q10 22 6 24" stroke="#5a8a3a" stroke-width="0.8" fill="none"/>
            <path d="M20 22 Q16 16 12 18" stroke="#5a8a3a" stroke-width="0.8" fill="none"/>
            <path d="M16 30 Q20 24 24 28" stroke="#5a8a3a" stroke-width="0.8" fill="none"/>
            <path d="M22 24 Q26 18 30 22" stroke="#5a8a3a" stroke-width="0.8" fill="none"/>
            <path d="M28 18 Q32 12 36 16" stroke="#5a8a3a" stroke-width="0.8" fill="none"/>
          </g>
        </svg>
      SVG
    },
    "chanterelle" => {
      name: "Chanterelle",
      name_ro: "Gălbiori",
      latin: "Cantharellus cibarius",
      description: "Golden trumpets of the forest floor. Chanterelles love mossy, damp woods and appear in flushes after warm summer rains.",
      description_ro: "Trompetele aurii ale pădurii. Gălbiorii adoră pădurile umede cu mușchi și apar în valuri după ploile calde de vară.",
      season_months: [6, 7, 8, 9, 10],
      temp_range: { ideal_min: 15, ideal_max: 25, abs_min: 10, abs_max: 30 },
      rain_range: { ideal_min: 20, ideal_max: 55, abs_min: 8, abs_max: 85 },
      delay_days: { ideal_min: 2, ideal_max: 5, abs_min: 2, abs_max: 7 },
      # Chanterelle fruiting correlates with temps 1-2 weeks prior.
      # 7-day average matches the literature on thermal integration.
      temp_window: 7,
      # Chanterelles love deciduous/mixed forests, ok in coniferous, rare in grassland
      preferred_terrain: { ideal: ["deciduous", "mixed"], partial: ["coniferous", "scrubland", "park", "wetland"], bad: ["grassland", "orchard", "farmland", "water"] },
      tips: [
        "#{IconHelper.icon(:moss)} Mossy hardwood and mixed forests, near oak, beech, birch",
        "#{IconHelper.icon(:droplet)} Damp, shaded ravines and stream banks",
        "#{IconHelper.icon(:fern)} Under blueberry and fern cover",
        "#{IconHelper.icon(:umbrella)} Look 2-5 days after warm summer rain",
        "#{IconHelper.icon(:moss)} Follow moss trails — chanterelles love moss",
        "#{IconHelper.icon(:sparkle)} Their golden color pops on rainy mornings",
        "#{IconHelper.icon(:hand_pick)} Gently twist and pull, don't cut — they regrow"
      ],
      tips_ro: [
        "#{IconHelper.icon(:moss)} Păduri de foioase și mixte cu mușchi, lângă stejari, fagi, mesteceni",
        "#{IconHelper.icon(:droplet)} Ravene umede și maluri de pâraie",
        "#{IconHelper.icon(:fern)} Sub afini și ferigi",
        "#{IconHelper.icon(:umbrella)} Caută la 2-5 zile după ploaie caldă de vară",
        "#{IconHelper.icon(:moss)} Urmează cărările cu mușchi — gălbiorii adoră mușchiul",
        "#{IconHelper.icon(:sparkle)} Culoarea lor aurie se vede bine în dimineți ploioase",
        "#{IconHelper.icon(:hand_pick)} Răsucește ușor și trage, nu tăia — cresc din nou"
      ],
      color: "#DAA520",
      gradient_from: "#c9941a",
      gradient_to: "#f0c040",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Chanterelle_Cantharellus_cibarius.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Cantharellus_cibarius_(GB%3D_Chanterelle,_D%3D_Pfifferling,_Reherling,_Eierschwamm,_NL%3D_Hanenkam)_at_Wofheze_at_30_July_2015_-_panoramio.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/100904_Li%C5%A1ka_obecn%C3%A1_(Cantharellus_cibarius)_0004.JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="chant-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#a8c888"/>
              <stop offset="50%" stop-color="#8aad6a"/>
              <stop offset="100%" stop-color="#5a5a38"/>
            </linearGradient>
            <linearGradient id="chant-body" x1="0.3" y1="1" x2="0.7" y2="0">
              <stop offset="0%" stop-color="#d49018"/>
              <stop offset="40%" stop-color="#e8a820"/>
              <stop offset="100%" stop-color="#f0c840"/>
            </linearGradient>
            <linearGradient id="chant-inner" x1="0" y1="1" x2="0" y2="0">
              <stop offset="0%" stop-color="#c88818"/>
              <stop offset="100%" stop-color="#e0b030"/>
            </linearGradient>
            <radialGradient id="chant-shine" cx="0.35" cy="0.3" r="0.5">
              <stop offset="0%" stop-color="#f8d860" stop-opacity="0.4"/>
              <stop offset="100%" stop-color="#e8a820" stop-opacity="0"/>
            </radialGradient>
            <filter id="chant-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#chant-bg)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="282" rx="220" ry="28" fill="#4a4a28" opacity="0.25"/>
          <ellipse cx="200" cy="278" rx="200" ry="18" fill="#5a5a30" opacity="0.2"/>
          <!-- Moss carpet -->
          <g opacity="0.35">
            <circle cx="65" cy="273" r="9" fill="#4a8a2a"/>
            <circle cx="78" cy="270" r="6" fill="#5a9a3a"/>
            <circle cx="58" cy="276" r="5" fill="#3a7a1a"/>
            <circle cx="90" cy="271" r="4" fill="#5a9a3a"/>
            <circle cx="330" cy="271" r="8" fill="#4a8a2a"/>
            <circle cx="342" cy="268" r="6" fill="#5a9a3a"/>
            <circle cx="322" cy="274" r="5" fill="#3a7a1a"/>
            <circle cx="352" cy="272" r="4" fill="#5a9a3a"/>
            <circle cx="150" cy="276" r="5" fill="#4a8a2a"/>
            <circle cx="245" cy="275" r="6" fill="#4a8a2a"/>
            <circle cx="255" cy="273" r="4" fill="#5a9a3a"/>
          </g>
          <!-- Fallen leaves -->
          <path d="M100 270 Q112 262 120 268 Q114 256 104 258 Q96 262 100 270 Z" fill="#6a7a28" opacity="0.3"/>
          <line x1="100" y1="270" x2="115" y2="260" stroke="#5a6a20" stroke-width="0.5" opacity="0.3"/>
          <path d="M290 268 Q300 260 310 266 Q304 256 296 258 Q288 262 290 268 Z" fill="#7a8a30" opacity="0.25"/>
          <!-- Small twigs -->
          <line x1="170" y1="278" x2="195" y2="274" stroke="#5a5030" stroke-width="1" opacity="0.25"/>
          <line x1="210" y1="277" x2="235" y2="273" stroke="#5a5030" stroke-width="0.8" opacity="0.2"/>
          <!-- Main chanterelle with shadow -->
          <g filter="url(#chant-shadow)">
            <!-- Stem - tapers from narrow base to wide funnel -->
            <path d="M192 278 Q188 262 186 245 Q184 228 183 215 Q182 202 184 192 L216 192 Q218 202 217 215 Q216 228 214 245 Q212 262 208 278 Z" fill="url(#chant-body)"/>
            <!-- Stem texture -->
            <path d="M194 275 Q193 258 192 238 Q192 218 193 198" stroke="#c89018" stroke-width="0.6" fill="none" opacity="0.3"/>
            <path d="M200 278 Q200 255 200 235 Q200 215 200 195" stroke="#c89018" stroke-width="0.5" fill="none" opacity="0.25"/>
            <path d="M206 275 Q207 258 208 238 Q208 218 207 198" stroke="#c89018" stroke-width="0.6" fill="none" opacity="0.3"/>
            <!-- Left stem shadow -->
            <path d="M192 278 Q188 262 186 245 Q184 228 183 215 Q182 202 184 192 L190 192 Q188 205 188 218 Q188 235 190 252 Q191 265 194 278 Z" fill="#b07810" opacity="0.2"/>
            <!-- Funnel/trumpet cap - organic wavy edges -->
            <path d="M184 192 Q178 178 168 162 Q158 148 142 132 Q134 124 124 118
                     L128 112 Q140 118 150 128 Q162 140 172 156
                     Q180 145 190 136 Q198 128 200 124
                     Q202 128 210 136 Q220 145 228 156
                     Q238 140 250 128 Q260 118 272 112
                     L276 118 Q266 124 258 132 Q242 148 232 162 Q222 178 216 192 Z"
                  fill="url(#chant-body)"/>
            <!-- Cap highlight -->
            <path d="M184 192 Q178 178 168 162 Q158 148 142 132 Q134 124 124 118
                     L128 112 Q140 118 150 128 Q160 140 168 152 Q172 148 176 155 Q180 145 188 136 Q196 128 200 124
                     Q198 130 192 140 Q186 152 182 168 Q180 178 184 192 Z"
                  fill="url(#chant-shine)"/>
            <!-- False gill ridges (forked, running down from cap edge) -->
            <g stroke="#c08015" fill="none" opacity="0.4">
              <!-- Left side gills -->
              <path d="M186 192 Q180 175 170 158 Q162 145 150 132" stroke-width="0.9"/>
              <path d="M188 192 Q184 178 176 164 Q170 152 160 140" stroke-width="0.8"/>
              <path d="M190 192 Q188 180 183 168 Q178 156 170 146" stroke-width="0.7"/>
              <path d="M193 192 Q192 180 189 170 Q186 160 180 150" stroke-width="0.7"/>
              <path d="M196 192 Q196 178 194 168 Q192 158 188 148" stroke-width="0.6"/>
              <!-- Right side gills -->
              <path d="M214 192 Q220 175 230 158 Q238 145 250 132" stroke-width="0.9"/>
              <path d="M212 192 Q216 178 224 164 Q230 152 240 140" stroke-width="0.8"/>
              <path d="M210 192 Q212 180 217 168 Q222 156 230 146" stroke-width="0.7"/>
              <path d="M207 192 Q208 180 211 170 Q214 160 220 150" stroke-width="0.7"/>
              <path d="M204 192 Q204 178 206 168 Q208 158 212 148" stroke-width="0.6"/>
              <!-- Gill forks -->
              <path d="M170 158 Q166 152 158 144" stroke-width="0.5"/>
              <path d="M176 164 Q174 160 168 154" stroke-width="0.5"/>
              <path d="M230 158 Q234 152 242 144" stroke-width="0.5"/>
              <path d="M224 164 Q226 160 232 154" stroke-width="0.5"/>
            </g>
            <!-- Wavy cap edge detail -->
            <path d="M124 118 Q128 114 128 112" stroke="#b88018" stroke-width="1" fill="none" opacity="0.3"/>
            <path d="M276 118 Q274 114 272 112" stroke="#b88018" stroke-width="1" fill="none" opacity="0.3"/>
            <!-- Cap outer edge shadow (right side) -->
            <path d="M228 156 Q238 140 250 128 Q260 118 272 112
                     L276 118 Q266 124 258 132 Q246 144 236 158 Q226 172 220 186 Z"
                  fill="#a07010" opacity="0.15"/>
          </g>
          <!-- end main chanterelle -->
          <!-- Grass tufts -->
          <path d="M135 276 Q137 264 133 254" stroke="#4a8a2a" stroke-width="1.4" fill="none" opacity="0.4"/>
          <path d="M139 277 Q140 266 143 256" stroke="#5a9a3a" stroke-width="1.1" fill="none" opacity="0.35"/>
          <path d="M260 275 Q258 264 262 255" stroke="#4a8a2a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M264 276 Q266 265 263 256" stroke="#5a9a3a" stroke-width="1" fill="none" opacity="0.3"/>
          <!-- Fern frond -->
          <g opacity="0.25" transform="translate(310, 248) scale(0.6)">
            <path d="M0 40 Q10 30 20 20 Q30 10 40 0" stroke="#4a8a2a" stroke-width="1.5" fill="none"/>
            <path d="M8 34 Q4 28 0 30" stroke="#4a8a2a" stroke-width="0.8" fill="none"/>
            <path d="M14 28 Q10 22 6 24" stroke="#4a8a2a" stroke-width="0.8" fill="none"/>
            <path d="M20 22 Q16 16 12 18" stroke="#4a8a2a" stroke-width="0.8" fill="none"/>
            <path d="M16 30 Q20 24 24 28" stroke="#4a8a2a" stroke-width="0.8" fill="none"/>
            <path d="M22 24 Q26 18 30 22" stroke="#4a8a2a" stroke-width="0.8" fill="none"/>
            <path d="M28 18 Q32 12 36 16" stroke="#4a8a2a" stroke-width="0.8" fill="none"/>
          </g>
        </svg>
      SVG
    },
    "oyster" => {
      name: "Oyster Mushroom",
      name_ro: "Păstrăvul de fag",
      latin: "Pleurotus ostreatus",
      description: "The shelf-shaped survivor of autumn and winter. Oyster mushrooms cluster on dead and dying hardwoods — beech, oak, poplar — and can fruit even after the first frosts.",
      description_ro: "Supraviețuitorul toamnei și iernii, în formă de scoică. Păstrăvul de fag crește în grupuri pe lemn mort de fag, stejar și plop — și poate fructifica chiar și după primele înghețuri.",
      season_months: [3, 4, 5, 9, 10, 11, 12],
      temp_range: { ideal_min: 5, ideal_max: 20, abs_min: -5, abs_max: 26 },
      rain_range: { ideal_min: 5, ideal_max: 40, abs_min: 1, abs_max: 80 },
      delay_days: { ideal_min: 2, ideal_max: 5, abs_min: 1, abs_max: 8 },
      # Oyster mushrooms respond quickly to cold snaps.
      # 5-day average captures the autumn temperature drops that trigger fruiting.
      temp_window: 5,
      # Primary flush is autumn/winter; spring is secondary (lighter yields).
      peak_months: [9, 10, 11, 12],
      # Strict wood-decomposer: needs forests with deadwood. Parks OK (fallen branches).
      preferred_terrain: { ideal: ["deciduous", "mixed"], partial: ["coniferous", "scrubland", "park", "wetland"], bad: ["grassland", "farmland", "orchard", "water"] },
      tips: [
        "#{IconHelper.icon(:log)} Fallen logs, stumps, and dead beech, oak, poplar, or willow",
        "#{IconHelper.icon(:snowflake)} Cool autumn nights (below 11\u00B0C) trigger fruiting",
        "#{IconHelper.icon(:rain_heavy)} Check 2\u20135 days after autumn rain",
        "#{IconHelper.icon(:fog)} They survive frost \u2014 keep looking into December",
        "#{IconHelper.icon(:map_pin)} Return to fallen-tree spots \u2014 they fruit repeatedly",
        "#{IconHelper.icon(:hand_pick)} Twist gently at the base \u2014 leave the smallest ones"
      ],
      tips_ro: [
        "#{IconHelper.icon(:log)} Bușteni căzuți, cioate și fagi, stejari, plopi sau sălcii morți",
        "#{IconHelper.icon(:snowflake)} Nopțile reci de toamnă (sub 11\u00B0C) declanșează fructificarea",
        "#{IconHelper.icon(:rain_heavy)} Verifică la 2\u20135 zile după ploaia de toamnă",
        "#{IconHelper.icon(:fog)} Rezistă la îngheț \u2014 continuă să cauți până în decembrie",
        "#{IconHelper.icon(:map_pin)} Revino la locurile cu arbori căzuți \u2014 fructifică repetat",
        "#{IconHelper.icon(:hand_pick)} Răsucește ușor la bază \u2014 lasă-i pe cei mici"
      ],
      color: "#708090",
      gradient_from: "#5a6a78",
      gradient_to: "#8a9aa8",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Pleurotus_ostreatus,_Japan_1.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Pleurotus_ostreatus_1.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Austern-Seitling_Austernpilz_Pleurotus_ostreatus.JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="oyster-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#a0b8a0"/>
              <stop offset="40%" stop-color="#889a80"/>
              <stop offset="100%" stop-color="#5a5040"/>
            </linearGradient>
            <linearGradient id="oyster-cap1" x1="0.2" y1="0" x2="0.8" y2="1">
              <stop offset="0%" stop-color="#a0aab4"/>
              <stop offset="40%" stop-color="#7a8a98"/>
              <stop offset="100%" stop-color="#5a6878"/>
            </linearGradient>
            <linearGradient id="oyster-cap2" x1="0.3" y1="0" x2="0.7" y2="1">
              <stop offset="0%" stop-color="#95a0ac"/>
              <stop offset="50%" stop-color="#6a7a88"/>
              <stop offset="100%" stop-color="#4a5a68"/>
            </linearGradient>
            <linearGradient id="oyster-cap3" x1="0.2" y1="0.2" x2="0.9" y2="1">
              <stop offset="0%" stop-color="#8a96a4"/>
              <stop offset="50%" stop-color="#6a7888"/>
              <stop offset="100%" stop-color="#505e6e"/>
            </linearGradient>
            <linearGradient id="oyster-bark-v" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#6b5a40"/>
              <stop offset="50%" stop-color="#5a4830"/>
              <stop offset="100%" stop-color="#4a3820"/>
            </linearGradient>
            <!-- Inner heartwood exposed at break -->
            <radialGradient id="oyster-heartwood" cx="0.45" cy="0.5" r="0.5">
              <stop offset="0%" stop-color="#8a7858"/>
              <stop offset="60%" stop-color="#6b5a40"/>
              <stop offset="100%" stop-color="#5a4830"/>
            </radialGradient>
            <filter id="oyster-shadow" x="-10%" y="-10%" width="130%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="3"/>
              <feOffset dx="2" dy="4"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#oyster-bg)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="285" rx="220" ry="25" fill="#4a4030" opacity="0.25"/>
          <!-- Standing dead tree trunk -->
          <g>
            <!-- Trunk body — wide, slightly irregular, slight lean -->
            <path d="M148 280 Q144 180 146 100 L146 48 L148 42 L234 42 L236 48 L234 100 Q236 180 232 280 Z" fill="url(#oyster-bark-v)"/>
            <!-- Bark texture — deep vertical cracks (dead tree, drying/splitting) -->
            <path d="M162 48 Q160 130 163 210 Q164 250 162 278" stroke="#3e2e18" stroke-width="1.8" fill="none" opacity="0.35"/>
            <path d="M178 44 Q176 110 179 190 Q180 240 178 278" stroke="#3e2e18" stroke-width="1.3" fill="none" opacity="0.28"/>
            <path d="M195 44 Q197 120 194 205 Q193 245 195 278" stroke="#3e2e18" stroke-width="1.3" fill="none" opacity="0.28"/>
            <path d="M212 44 Q210 115 213 200 Q214 248 212 278" stroke="#3e2e18" stroke-width="1.5" fill="none" opacity="0.32"/>
            <path d="M226 48 Q224 130 227 215 Q228 252 226 278" stroke="#3e2e18" stroke-width="1.2" fill="none" opacity="0.25"/>
            <!-- Horizontal bark plates (peeling on dead tree) -->
            <path d="M148 80 Q170 78 195 79 Q218 80 234 82" stroke="#3e2e18" stroke-width="0.7" fill="none" opacity="0.2"/>
            <path d="M148 135 Q175 133 200 134 Q225 135 234 137" stroke="#3e2e18" stroke-width="0.7" fill="none" opacity="0.18"/>
            <path d="M148 195 Q172 193 198 194 Q222 195 234 196" stroke="#3e2e18" stroke-width="0.7" fill="none" opacity="0.18"/>
            <path d="M148 248 Q178 246 205 247 Q228 248 234 249" stroke="#3e2e18" stroke-width="0.6" fill="none" opacity="0.15"/>
            <!-- Bark highlight (left light source) -->
            <path d="M155 60 Q153 130 156 200 Q157 240 155 270" stroke="#7a6a50" stroke-width="3" fill="none" opacity="0.12"/>
            <!-- Dark right edge -->
            <path d="M228 55 Q226 130 229 210 Q230 250 228 275" stroke="#3a2a15" stroke-width="2" fill="none" opacity="0.15"/>

            <!-- ── Broken top: oval cross-section with jagged edge ── -->
            <!-- Oval heartwood face (the sawn/broken cross-section) -->
            <ellipse cx="190" cy="42" rx="44" ry="10" fill="url(#oyster-heartwood)"/>
            <!-- Growth rings on the cross-section -->
            <ellipse cx="190" cy="42" rx="30" ry="7" fill="none" stroke="#5a4830" stroke-width="0.6" opacity="0.3"/>
            <ellipse cx="190" cy="42" rx="18" ry="4" fill="none" stroke="#5a4830" stroke-width="0.5" opacity="0.25"/>
            <ellipse cx="190" cy="42" rx="6" ry="2" fill="#4a3820" opacity="0.3"/>
            <!-- Jagged splinter sticking up (left side of break) -->
            <path d="M152 42 L148 18 L155 30 L158 42" fill="#5a4830"/>
            <path d="M150 20 L152 38" stroke="#6b5a40" stroke-width="0.8" fill="none" opacity="0.3"/>
            <!-- Smaller splinter (right-center) -->
            <path d="M206 41 L210 26 L214 41" fill="#5a4830"/>
            <path d="M209 28 L211 40" stroke="#6b5a40" stroke-width="0.6" fill="none" opacity="0.3"/>
            <!-- Tiny splinter (far right) -->
            <path d="M228 42 L232 34 L234 42" fill="#5a4830" opacity="0.8"/>

            <!-- ── Branch stubs ── -->
            <!-- Left branch stub (broken short, angled up-left, ~y=70) -->
            <path d="M148 72 Q130 62 118 50" stroke="#5a4830" stroke-width="9" stroke-linecap="round" fill="none"/>
            <path d="M148 72 Q130 62 118 50" stroke="#6b5a40" stroke-width="5" stroke-linecap="round" fill="none"/>
            <!-- Tiny broken tip on left stub -->
            <path d="M118 50 L114 42 L120 46" fill="#5a4830" opacity="0.5"/>

            <!-- Right branch stub (shorter, angled up-right, ~y=84 — above mushrooms) -->
            <path d="M234 86 Q252 78 264 68" stroke="#5a4830" stroke-width="7" stroke-linecap="round" fill="none"/>
            <path d="M234 86 Q252 78 264 68" stroke="#6b5a40" stroke-width="3.5" stroke-linecap="round" fill="none"/>

            <!-- Lower left twig stub (small, ~y=180) -->
            <path d="M148 182 Q136 176 128 168" stroke="#5a4830" stroke-width="5" stroke-linecap="round" fill="none"/>
            <path d="M148 182 Q136 176 128 168" stroke="#6b5a40" stroke-width="2.5" stroke-linecap="round" fill="none"/>

            <!-- Moss patches on trunk (north-facing left side) -->
            <ellipse cx="153" cy="225" rx="7" ry="18" fill="#5a8a3a" opacity="0.25"/>
            <ellipse cx="157" cy="260" rx="9" ry="12" fill="#6a9a4a" opacity="0.2"/>
            <ellipse cx="150" cy="155" rx="5" ry="10" fill="#4a7a2a" opacity="0.18"/>
            <!-- Lichen spot -->
            <circle cx="218" cy="245" r="6" fill="#8a9a6a" opacity="0.15"/>
            <circle cx="165" cy="108" r="4" fill="#8a9a6a" opacity="0.12"/>
          </g>

          <!-- Oyster mushroom cluster (shelves from RIGHT side of trunk) -->
          <g filter="url(#oyster-shadow)">
            <!-- Upper large cap — shelf protruding right ~y=100 -->
            <path d="M228 90 Q260 80 295 85 Q320 92 325 108 Q328 125 310 135 Q290 142 260 140 Q238 136 230 125 Z" fill="url(#oyster-cap1)"/>
            <path d="M235 95 Q258 88 285 90 Q270 95 255 105 Q242 112 235 118 Z" fill="#b0bcc8" opacity="0.3"/>
            <!-- Gill lines underneath -->
            <path d="M240 130 Q265 135 290 132" stroke="#d8ccb8" stroke-width="0.8" fill="none" opacity="0.5"/>
            <path d="M245 134 Q268 138 288 135" stroke="#d8ccb8" stroke-width="0.7" fill="none" opacity="0.4"/>
            <path d="M250 137 Q270 140 285 138" stroke="#d8ccb8" stroke-width="0.6" fill="none" opacity="0.35"/>

            <!-- Middle large cap — shelf at ~y=150 -->
            <path d="M230 145 Q268 132 310 140 Q340 150 342 168 Q342 185 320 192 Q295 198 262 195 Q238 190 232 175 Z" fill="url(#oyster-cap2)"/>
            <path d="M238 150 Q270 140 300 145 Q285 152 268 162 Q252 170 240 172 Z" fill="#a0aeb8" opacity="0.3"/>
            <!-- Gill lines -->
            <path d="M245 185 Q275 192 305 187" stroke="#d8ccb8" stroke-width="0.8" fill="none" opacity="0.5"/>
            <path d="M250 189 Q278 194 302 190" stroke="#d8ccb8" stroke-width="0.7" fill="none" opacity="0.4"/>
            <path d="M255 192 Q280 196 298 193" stroke="#d8ccb8" stroke-width="0.6" fill="none" opacity="0.35"/>

            <!-- Lower medium cap — shelf at ~y=210 -->
            <path d="M228 205 Q255 195 285 200 Q308 208 310 222 Q310 235 295 240 Q272 245 250 242 Q234 238 230 225 Z" fill="url(#oyster-cap3)"/>
            <path d="M236 210 Q258 202 278 205 Q265 212 254 220 Q243 226 238 225 Z" fill="#98a4b0" opacity="0.3"/>
            <!-- Gill lines -->
            <path d="M242 234 Q262 240 282 236" stroke="#d8ccb8" stroke-width="0.7" fill="none" opacity="0.5"/>
            <path d="M246 237 Q265 242 280 239" stroke="#d8ccb8" stroke-width="0.6" fill="none" opacity="0.4"/>

            <!-- Tiny baby cap — between upper and middle -->
            <path d="M226 130 Q242 124 260 128 Q270 133 270 142 Q268 150 255 152 Q240 152 232 145 Z" fill="url(#oyster-cap1)"/>
            <path d="M232 133 Q245 128 255 131 Q248 135 242 140 Q236 143 234 141 Z" fill="#b0bcc8" opacity="0.25"/>
          </g>
          <!-- Small fallen leaves -->
          <ellipse cx="320" cy="272" rx="22" ry="5" fill="#7a6a30" opacity="0.3" transform="rotate(10 320 272)"/>
          <ellipse cx="80" cy="275" rx="18" ry="4" fill="#8a7a3a" opacity="0.25" transform="rotate(-15 80 275)"/>
          <!-- Grass tufts -->
          <path d="M60 278 Q58 265 62 255" stroke="#5a8a3a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M65 278 Q67 267 64 258" stroke="#6a9a4a" stroke-width="1" fill="none" opacity="0.3"/>
          <path d="M340 278 Q338 268 342 260" stroke="#5a8a3a" stroke-width="1.2" fill="none" opacity="0.3"/>
          <path d="M345 278 Q347 269 344 261" stroke="#6a9a4a" stroke-width="1" fill="none" opacity="0.25"/>
          <!-- Fern at base of trunk -->
          <path d="M132 275 Q125 258 117 248" stroke="#5a8a3a" stroke-width="1.5" fill="none" opacity="0.35"/>
          <path d="M136 275 Q130 260 126 252" stroke="#6a9a4a" stroke-width="1" fill="none" opacity="0.3"/>
          <path d="M142 275 Q148 260 155 250" stroke="#5a8a3a" stroke-width="1.2" fill="none" opacity="0.3"/>
        </svg>
      SVG
    },
    "saffron_milkcap" => {
      name: "Saffron Milk Cap",
      name_ro: "Râșcov",
      latin: "Lactarius deliciosus",
      description: "The prized orange treasure of pine forests. Saffron milk caps form mycorrhizal bonds with conifers and flush after autumn rains, oozing bright orange latex when cut.",
      description_ro: "Comoara portocalie a pădurilor de conifere. Râșcovul formează legături micorizale cu coniferele și apare după ploile de toamnă, eliberând un latex portocaliu viu la tăiere.",
      season_months: [8, 9, 10, 11],
      temp_range: { ideal_min: 8, ideal_max: 18, abs_min: 3, abs_max: 25 },
      rain_range: { ideal_min: 15, ideal_max: 45, abs_min: 5, abs_max: 70 },
      delay_days: { ideal_min: 3, ideal_max: 7, abs_min: 1, abs_max: 10 },
      # Mycorrhizal fruiting responds to sustained cooling after summer.
      # 5-day average captures the autumn temperature drop that triggers flushes.
      temp_window: 5,
      # Peak is September–October when autumn rains meet cooling temps.
      # August and November are secondary (early scouts / late stragglers).
      peak_months: [9, 10],
      # Obligate ectomycorrhizal with conifers — pine forests are essential.
      # Mixed forests work if pines are present. Pure deciduous = no chance.
      preferred_terrain: { ideal: ["coniferous"], partial: ["mixed", "scrubland", "park"], bad: ["deciduous", "grassland", "wetland", "orchard", "farmland", "water"] },
      tips: [
        "#{IconHelper.icon(:tree_conifer)} Always under pines — Scots pine, black pine, spruce edges",
        "#{IconHelper.icon(:fallen_leaf)} Look on needle-covered slopes with well-drained, acidic soil",
        "#{IconHelper.icon(:rain_heavy)} Best 3–7 days after good autumn rain",
        "#{IconHelper.icon(:leaf_autumn)} Peak in September–October when nights cool below 12°C",
        "#{IconHelper.icon(:droplet)} Cut the flesh — real ones ooze orange milk that turns green",
        "#{IconHelper.icon(:trail)} Check pine plantation edges and sunny clearings",
        "#{IconHelper.icon(:map_pin)} Return to known spots — the mycelium fruits year after year"
      ],
      tips_ro: [
        "#{IconHelper.icon(:tree_conifer)} Mereu sub pini — pin silvestru, pin negru, la marginea molidișurilor",
        "#{IconHelper.icon(:fallen_leaf)} Caută pe versanți cu ace de pin și sol acid, bine drenat",
        "#{IconHelper.icon(:rain_heavy)} Cel mai bine la 3–7 zile după o ploaie bună de toamnă",
        "#{IconHelper.icon(:leaf_autumn)} Vârf în septembrie–octombrie când nopțile scad sub 12°C",
        "#{IconHelper.icon(:droplet)} Taie carnea — cei autentici lasă un lapte portocaliu ce devine verde",
        "#{IconHelper.icon(:trail)} Verifică marginile plantațiilor de pin și poienile însorite",
        "#{IconHelper.icon(:map_pin)} Revino la locurile cunoscute — miceliul fructifică an de an"
      ],
      color: "#D2691E",
      gradient_from: "#c45a1a",
      gradient_to: "#e8924a",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Lactarius_Deliciosus.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Echte_Reizker_Lactarius_deliciosus.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Lactarius_deliciosus_rafax.JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="smc-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8aad70"/>
              <stop offset="50%" stop-color="#6a8d50"/>
              <stop offset="100%" stop-color="#5a4a30"/>
            </linearGradient>
            <linearGradient id="smc-cap-top" x1="0.2" y1="0" x2="0.8" y2="1">
              <stop offset="0%" stop-color="#e8924a"/>
              <stop offset="40%" stop-color="#d47830"/>
              <stop offset="100%" stop-color="#b86020"/>
            </linearGradient>
            <linearGradient id="smc-cap-under" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#e09040"/>
              <stop offset="100%" stop-color="#c87830"/>
            </linearGradient>
            <linearGradient id="smc-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#d4a060"/>
              <stop offset="25%" stop-color="#e8b878"/>
              <stop offset="75%" stop-color="#e8b878"/>
              <stop offset="100%" stop-color="#c89050"/>
            </linearGradient>
            <radialGradient id="smc-cap-shine" cx="0.35" cy="0.3" r="0.5">
              <stop offset="0%" stop-color="#f0b060" stop-opacity="0.5"/>
              <stop offset="100%" stop-color="#d47830" stop-opacity="0"/>
            </radialGradient>
            <filter id="smc-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#smc-bg)"/>
          <!-- Pine needle carpet -->
          <ellipse cx="200" cy="282" rx="220" ry="28" fill="#5a4a28" opacity="0.25"/>
          <ellipse cx="200" cy="278" rx="200" ry="18" fill="#6a5a30" opacity="0.2"/>
          <!-- Scattered pine needles -->
          <g opacity="0.35" stroke="#7a6a30" fill="none" stroke-width="0.7">
            <line x1="55" y1="274" x2="85" y2="269"/><line x1="58" y1="276" x2="88" y2="272"/>
            <line x1="62" y1="275" x2="78" y2="268"/>
            <line x1="290" y1="272" x2="325" y2="267"/><line x1="295" y1="274" x2="328" y2="270"/>
            <line x1="300" y1="273" x2="318" y2="266"/>
            <line x1="140" y1="278" x2="162" y2="274"/><line x1="143" y1="280" x2="168" y2="276"/>
            <line x1="235" y1="277" x2="258" y2="273"/><line x1="238" y1="279" x2="260" y2="275"/>
          </g>
          <!-- Pine cones -->
          <g opacity="0.3">
            <ellipse cx="95" cy="272" rx="6" ry="4" fill="#6a5020" transform="rotate(-15 95 272)"/>
            <path d="M90 271 L92 268 L94 271 L96 268 L98 271 L100 268" stroke="#5a4018" stroke-width="0.6" fill="none" transform="rotate(-15 95 272)"/>
            <ellipse cx="320" cy="270" rx="5" ry="3.5" fill="#6a5020" transform="rotate(10 320 270)"/>
            <path d="M316 269 L318 266 L320 269 L322 266 L324 269" stroke="#5a4018" stroke-width="0.6" fill="none" transform="rotate(10 320 270)"/>
          </g>
          <!-- Small moss patches -->
          <g opacity="0.3">
            <circle cx="72" cy="274" r="6" fill="#4a7a2a"/>
            <circle cx="80" cy="271" r="4" fill="#5a8a3a"/>
            <circle cx="340" cy="272" r="5" fill="#4a7a2a"/>
            <circle cx="348" cy="269" r="3.5" fill="#5a8a3a"/>
          </g>
          <!-- Main saffron milk cap with shadow -->
          <g filter="url(#smc-shadow)">
            <!-- Stem — short, stout, slightly tapered, with orange scrobicules -->
            <path d="M186 272 Q183 258 182 242 Q181 228 183 218 Q185 212 190 208 L210 208 Q215 212 217 218 Q219 228 218 242 Q217 258 214 272 Z" fill="url(#smc-stem)"/>
            <!-- Stem scrobicules (characteristic orange pits) -->
            <g fill="#c07030" opacity="0.4">
              <ellipse cx="192" cy="225" rx="2.5" ry="1.5"/><ellipse cx="196" cy="235" rx="2" ry="1.2"/>
              <ellipse cx="204" cy="220" rx="2" ry="1.3"/><ellipse cx="208" cy="232" rx="2.5" ry="1.5"/>
              <ellipse cx="200" cy="245" rx="2.2" ry="1.4"/><ellipse cx="194" cy="250" rx="2" ry="1.2"/>
              <ellipse cx="206" cy="248" rx="2.3" ry="1.3"/><ellipse cx="190" cy="238" rx="1.8" ry="1.1"/>
              <ellipse cx="210" cy="240" rx="2" ry="1.2"/><ellipse cx="198" cy="258" rx="2" ry="1.2"/>
            </g>
            <!-- Stem left shadow -->
            <path d="M186 272 Q183 258 182 242 Q181 228 183 218 Q185 212 190 208 L194 208 Q189 214 188 222 Q186 232 186 248 Q186 260 188 272 Z" fill="#b08040" opacity="0.2"/>
            <!-- Green bruise on stem (characteristic damage mark) -->
            <ellipse cx="205" cy="255" rx="4" ry="3" fill="#5a8a50" opacity="0.25"/>
            <!-- Gills (decurrent, crowded, visible at cap edge) -->
            <g stroke="#d08838" stroke-width="0.6" fill="none" opacity="0.55">
              <path d="M130 198 Q165 195 200 206"/>
              <path d="M135 195 Q165 192 200 204"/>
              <path d="M140 192 Q168 190 200 202"/>
              <path d="M148 189 Q172 188 200 200"/>
              <path d="M156 187 Q176 186 200 198"/>
              <path d="M200 206 Q235 195 270 198"/>
              <path d="M200 204 Q235 192 265 195"/>
              <path d="M200 202 Q232 190 260 192"/>
              <path d="M200 200 Q228 188 252 189"/>
              <path d="M200 198 Q224 186 244 187"/>
            </g>
            <!-- Cap — broad, convex depressed to funnel-shaped -->
            <path d="M118 194 Q122 172 148 155 Q175 142 200 140 Q225 142 252 155 Q278 172 282 194 Q260 200 200 204 Q140 200 118 194 Z" fill="url(#smc-cap-top)"/>
            <!-- Cap concentric zones (characteristic ring pattern) -->
            <g stroke="#b05820" stroke-width="0.8" fill="none" opacity="0.3">
              <ellipse cx="200" cy="170" rx="70" ry="22"/>
              <ellipse cx="200" cy="172" rx="55" ry="17"/>
              <ellipse cx="200" cy="174" rx="40" ry="12"/>
              <ellipse cx="200" cy="176" rx="25" ry="8"/>
            </g>
            <!-- Cap central depression -->
            <ellipse cx="200" cy="168" rx="18" ry="8" fill="#a85820" opacity="0.35"/>
            <!-- Cap glossy shine -->
            <path d="M148 158 Q170 146 200 143 Q218 143 235 148 Q215 143 195 148 Q170 156 158 170 Q152 178 148 188 Z" fill="url(#smc-cap-shine)"/>
            <!-- Cap right shadow -->
            <path d="M258 158 Q272 168 278 184 Q280 190 282 194 L268 196 Q266 182 256 168 Q252 160 258 158 Z" fill="#8a4010" opacity="0.18"/>
            <!-- Cap surface color variation — darker orange patches -->
            <g fill="#b85818" opacity="0.12">
              <ellipse cx="170" cy="168" rx="12" ry="6"/>
              <ellipse cx="230" cy="166" rx="10" ry="5"/>
              <ellipse cx="200" cy="158" rx="8" ry="4"/>
              <ellipse cx="155" cy="178" rx="9" ry="5"/>
              <ellipse cx="245" cy="176" rx="8" ry="4"/>
            </g>
            <!-- Green staining on cap edge (characteristic aging/damage mark) -->
            <path d="M135 192 Q140 188 148 190 Q142 194 135 192 Z" fill="#5a8a50" opacity="0.2"/>
            <path d="M262 190 Q268 186 274 190 Q270 194 262 192 Z" fill="#5a8a50" opacity="0.18"/>
          </g>
          <!-- Small conifer seedling -->
          <g opacity="0.35" transform="translate(50, 250) scale(0.7)">
            <line x1="10" y1="40" x2="10" y2="18" stroke="#5a4020" stroke-width="1.2"/>
            <polygon points="10,8 4,22 16,22" fill="#3a7a30"/>
            <polygon points="10,14 5,26 15,26" fill="#2d6a25"/>
            <polygon points="10,20 6,30 14,30" fill="#2d6a25"/>
          </g>
          <!-- Grass tufts -->
          <path d="M255 275 Q253 264 257 255" stroke="#5a8a3a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M259 276 Q261 265 258 256" stroke="#6a9a4a" stroke-width="1" fill="none" opacity="0.3"/>
          <path d="M148 276 Q146 266 150 258" stroke="#5a8a3a" stroke-width="1.2" fill="none" opacity="0.3"/>
          <path d="M152 276 Q153 268 150 260" stroke="#6a9a4a" stroke-width="1" fill="none" opacity="0.25"/>
        </svg>
      SVG
    },
    "parasol" => {
      name: "Parasol Mushroom",
      name_ro: "Piciorul căprioarei",
      latin: "Macrolepiota procera",
      description: "The towering parasol of meadows and forest edges. This majestic mushroom can reach 40 cm tall, its flat scaly cap opening like an umbrella over a snakeskin-patterned stem.",
      description_ro: "Umbrela maiestuoasă a pajiștilor și marginilor de pădure. Această ciupercă impunătoare poate atinge 40 cm înălțime, cu pălăria plată și solzoasă deschisă ca o umbrelă peste o tijă cu model de piele de șarpe.",
      season_months: [6, 7, 8, 9, 10],
      temp_range: { ideal_min: 14, ideal_max: 22, abs_min: 7, abs_max: 28 },
      rain_range: { ideal_min: 15, ideal_max: 50, abs_min: 5, abs_max: 75 },
      delay_days: { ideal_min: 3, ideal_max: 7, abs_min: 1, abs_max: 10 },
      # Saprophytic — responds to sustained warmth + moisture.
      # 7-day average captures the summer heat that drives decomposition.
      temp_window: 7,
      # Peak is August–October when summer thunderstorms meet warm soil.
      # June and July are secondary (early scouts after first big rains).
      peak_months: [8, 9, 10],
      # Saprophytic grassland/edge species — loves open, well-lit areas.
      # Meadows & light deciduous woods are ideal. Dense conifer = too dark/acidic.
      preferred_terrain: { ideal: ["grassland", "deciduous", "park"], partial: ["mixed", "scrubland", "farmland", "orchard"], bad: ["coniferous", "wetland", "water"] },
      tips: [
        "#{IconHelper.icon(:herb)} Meadows, pastures, and grassy forest edges — it loves open light",
        "#{IconHelper.icon(:storm)} Best 3–7 days after heavy summer thunderstorms",
        "#{IconHelper.icon(:sun)} Look on sunny, well-drained slopes with rich soil",
        "#{IconHelper.icon(:sparkle)} Fairy rings — they often grow in circles!",
        "#{IconHelper.icon(:hand_pick)} Only take the cap — the tough stem is not worth eating",
        "#{IconHelper.icon(:checkmark)} Double-ring on the stem slides up and down — key ID feature",
        "#{IconHelper.icon(:map_pin)} Return to known meadows — they fruit in the same spots yearly"
      ],
      tips_ro: [
        "#{IconHelper.icon(:herb)} Pajiști, pășuni și marginile înierbare ale pădurilor — adoră lumina",
        "#{IconHelper.icon(:storm)} Cel mai bine la 3–7 zile după furtuni puternice de vară",
        "#{IconHelper.icon(:sun)} Caută pe versanți însoriti, bine drenați, cu sol bogat",
        "#{IconHelper.icon(:sparkle)} Cercuri de vrăjitoare — cresc adesea în cercuri!",
        "#{IconHelper.icon(:hand_pick)} Ia doar pălăria — piciorul e prea tare pentru gătit",
        "#{IconHelper.icon(:checkmark)} Inelul dublu de pe picior alunecă sus-jos — semn distinctiv",
        "#{IconHelper.icon(:map_pin)} Revino la pajiștile cunoscute — fructifică în aceleași locuri"
      ],
      color: "#A0826D",
      gradient_from: "#8a6a55",
      gradient_to: "#c4a088",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Macrolepiota_procera.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Macrolepiota_procera_2018_G1.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Lepiota_procera_-_Macrolepiota_procera_-_Parasol_-_Riesenschirmpilz_-_03.jpg?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="par-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#a8c8e0"/>
              <stop offset="35%" stop-color="#c8d8a0"/>
              <stop offset="100%" stop-color="#8a9a58"/>
            </linearGradient>
            <linearGradient id="par-cap-top" x1="0.2" y1="0" x2="0.8" y2="1">
              <stop offset="0%" stop-color="#e0d0b8"/>
              <stop offset="40%" stop-color="#c8b898"/>
              <stop offset="100%" stop-color="#a89070"/>
            </linearGradient>
            <linearGradient id="par-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#c0a888"/>
              <stop offset="25%" stop-color="#d8c8b0"/>
              <stop offset="75%" stop-color="#d8c8b0"/>
              <stop offset="100%" stop-color="#b8a080"/>
            </linearGradient>
            <linearGradient id="par-gills" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#f0e8dc"/>
              <stop offset="100%" stop-color="#e0d4c0"/>
            </linearGradient>
            <radialGradient id="par-umbo" cx="0.5" cy="0.5" r="0.5">
              <stop offset="0%" stop-color="#6a5030"/>
              <stop offset="80%" stop-color="#8a6a48"/>
              <stop offset="100%" stop-color="#a88060"/>
            </radialGradient>
            <filter id="par-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#par-bg)"/>
          <!-- Grassy meadow floor -->
          <ellipse cx="200" cy="282" rx="220" ry="28" fill="#6a8a38" opacity="0.3"/>
          <ellipse cx="200" cy="278" rx="200" ry="18" fill="#7a9a48" opacity="0.25"/>
          <!-- Grass blades background -->
          <g opacity="0.4" stroke="#5a8a30" fill="none">
            <path d="M50 280 Q52 264 48 252" stroke-width="1.5"/>
            <path d="M55 280 Q58 266 62 255" stroke-width="1.2"/>
            <path d="M60 280 Q57 268 54 258" stroke-width="1"/>
            <path d="M340 278 Q338 264 342 254" stroke-width="1.4"/>
            <path d="M345 278 Q348 265 344 256" stroke-width="1.1"/>
            <path d="M350 278 Q353 266 356 257" stroke-width="1"/>
            <path d="M110 280 Q112 268 108 260" stroke-width="1.2"/>
            <path d="M115 280 Q118 270 120 262" stroke-width="1"/>
            <path d="M280 279 Q278 266 282 258" stroke-width="1.3"/>
            <path d="M285 279 Q288 268 284 260" stroke-width="1"/>
          </g>
          <!-- Wildflowers -->
          <g opacity="0.4">
            <circle cx="75" cy="268" r="2.5" fill="#e8d040"/>
            <circle cx="78" cy="272" r="2" fill="#e8d040"/>
            <circle cx="330" cy="270" r="2.5" fill="#d0a0d0"/>
            <circle cx="325" cy="274" r="2" fill="#d0a0d0"/>
            <circle cx="160" cy="276" r="2" fill="#f0f0a0"/>
            <circle cx="245" cy="275" r="2.2" fill="#e8d040"/>
          </g>
          <!-- Main parasol mushroom with shadow -->
          <g filter="url(#par-shadow)">
            <!-- Stem — very tall, thin, with bulbous base -->
            <path d="M194 276 Q191 248 190 220 Q189 190 190 160 Q190 140 192 126 Q194 120 197 118 L203 118 Q206 120 208 126 Q210 140 210 160 Q211 190 210 220 Q209 248 206 276 Z" fill="url(#par-stem)"/>
            <!-- Stem bulbous base -->
            <ellipse cx="200" cy="274" rx="10" ry="5" fill="#c0a880" opacity="0.5"/>
            <!-- Snakeskin pattern on stem (characteristic zigzag bands) -->
            <g stroke="#8a6840" stroke-width="1" fill="none" opacity="0.4">
              <path d="M192 260 Q196 256 200 260 Q204 264 208 260"/>
              <path d="M191 245 Q195 241 200 245 Q205 249 209 245"/>
              <path d="M190 230 Q195 226 200 230 Q205 234 210 230"/>
              <path d="M190 215 Q195 211 200 215 Q205 219 210 215"/>
              <path d="M190 200 Q195 196 200 200 Q205 204 210 200"/>
              <path d="M190 185 Q195 181 200 185 Q205 189 210 185"/>
              <path d="M190 170 Q195 166 200 170 Q205 174 210 170"/>
              <path d="M191 155 Q195 151 200 155 Q205 159 209 155"/>
              <path d="M192 140 Q196 136 200 140 Q204 144 208 140"/>
            </g>
            <!-- Stem left shadow -->
            <path d="M194 276 Q191 248 190 220 Q189 190 190 160 Q190 140 192 126 Q194 120 197 118 L199 118 Q196 122 195 130 Q193 142 193 162 Q192 192 193 222 Q193 250 196 276 Z" fill="#a08860" opacity="0.2"/>
            <!-- Movable ring (double ring — characteristic ID feature) -->
            <ellipse cx="200" cy="125" rx="14" ry="3.5" fill="#e8dcc0"/>
            <ellipse cx="200" cy="125" rx="14" ry="3.5" stroke="#b8a080" stroke-width="0.8" fill="none"/>
            <ellipse cx="200" cy="123" rx="12" ry="2.5" fill="#f0e8d4"/>
            <path d="M187 125 Q188 128 200 130 Q212 128 213 125" fill="#d8c8a8" opacity="0.5"/>
            <!-- Gills — crowded, free, whitish, visible under cap -->
            <g stroke="#c8b898" stroke-width="0.5" fill="none" opacity="0.45">
              <path d="M120 108 Q155 100 200 114"/>
              <path d="M126 106 Q158 98 200 112"/>
              <path d="M132 104 Q160 97 200 110"/>
              <path d="M140 102 Q165 96 200 108"/>
              <path d="M148 100 Q170 95 200 106"/>
              <path d="M158 98 Q176 95 200 104"/>
              <path d="M200 114 Q245 100 280 108"/>
              <path d="M200 112 Q242 98 274 106"/>
              <path d="M200 110 Q240 97 268 104"/>
              <path d="M200 108 Q235 96 260 102"/>
              <path d="M200 106 Q230 95 252 100"/>
              <path d="M200 104 Q224 95 242 98"/>
            </g>
            <!-- Cap — broad, flat parasol shape with slight central bump -->
            <path d="M108 104 Q110 88 140 76 Q170 66 200 64 Q230 66 260 76 Q290 88 292 104 Q260 112 200 116 Q140 112 108 104 Z" fill="url(#par-cap-top)"/>
            <!-- Cap underside (gill base visible at edge) -->
            <path d="M108 104 Q140 112 200 116 Q260 112 292 104 Q270 108 200 110 Q130 108 108 104 Z" fill="url(#par-gills)" opacity="0.6"/>
            <!-- Central umbo (dark raised boss) -->
            <ellipse cx="200" cy="78" rx="14" ry="8" fill="url(#par-umbo)"/>
            <!-- Cap scales — brown, radiating outward from center (characteristic) -->
            <g fill="#8a6a40" opacity="0.35">
              <!-- Inner ring of scales -->
              <ellipse cx="180" cy="80" rx="5" ry="3" transform="rotate(-10 180 80)"/>
              <ellipse cx="220" cy="80" rx="5" ry="3" transform="rotate(10 220 80)"/>
              <ellipse cx="200" cy="70" rx="4" ry="3"/>
              <ellipse cx="190" cy="88" rx="5" ry="2.5" transform="rotate(-5 190 88)"/>
              <ellipse cx="210" cy="88" rx="5" ry="2.5" transform="rotate(5 210 88)"/>
              <!-- Middle ring of scales -->
              <ellipse cx="160" cy="86" rx="6" ry="3" transform="rotate(-15 160 86)"/>
              <ellipse cx="240" cy="86" rx="6" ry="3" transform="rotate(15 240 86)"/>
              <ellipse cx="170" cy="94" rx="5" ry="2.5" transform="rotate(-8 170 94)"/>
              <ellipse cx="230" cy="94" rx="5" ry="2.5" transform="rotate(8 230 94)"/>
              <ellipse cx="200" cy="94" rx="5" ry="2.5"/>
              <ellipse cx="148" cy="92" rx="5" ry="2.5" transform="rotate(-20 148 92)"/>
              <ellipse cx="252" cy="92" rx="5" ry="2.5" transform="rotate(20 252 92)"/>
              <!-- Outer ring of scales (smaller, sparser) -->
              <ellipse cx="135" cy="96" rx="4" ry="2" transform="rotate(-25 135 96)"/>
              <ellipse cx="265" cy="96" rx="4" ry="2" transform="rotate(25 265 96)"/>
              <ellipse cx="155" cy="100" rx="4" ry="2" transform="rotate(-12 155 100)"/>
              <ellipse cx="245" cy="100" rx="4" ry="2" transform="rotate(12 245 100)"/>
              <ellipse cx="180" cy="102" rx="4" ry="2"/>
              <ellipse cx="220" cy="102" rx="4" ry="2"/>
              <ellipse cx="122" cy="100" rx="3.5" ry="1.8" transform="rotate(-30 122 100)"/>
              <ellipse cx="278" cy="100" rx="3.5" ry="1.8" transform="rotate(30 278 100)"/>
            </g>
            <!-- Cap glossy highlight -->
            <path d="M145 78 Q170 68 200 66 Q218 66 235 70 Q215 66 195 72 Q168 80 155 92 Z" fill="#f0e8d8" opacity="0.25"/>
            <!-- Cap right shadow -->
            <path d="M265 80 Q282 88 289 98 Q290 102 292 104 L278 106 Q276 96 268 88 Z" fill="#7a6040" opacity="0.15"/>
          </g>
          <!-- Foreground grass tufts -->
          <g opacity="0.5" stroke="#5a8a30" fill="none">
            <path d="M140 278 Q138 264 142 254" stroke-width="1.5"/>
            <path d="M145 278 Q148 266 144 256" stroke-width="1.2"/>
            <path d="M150 278 Q152 268 156 258" stroke-width="1"/>
            <path d="M252 277 Q250 264 254 255" stroke-width="1.4"/>
            <path d="M257 277 Q260 266 256 257" stroke-width="1.1"/>
            <path d="M262 277 Q264 268 260 258" stroke-width="1"/>
          </g>
          <!-- Distant grass silhouette -->
          <g opacity="0.15" stroke="#4a6a20" fill="none" stroke-width="1.5">
            <path d="M0 280 Q10 268 8 255"/>
            <path d="M6 280 Q14 270 18 258"/>
            <path d="M390 280 Q385 268 388 256"/>
            <path d="M395 280 Q392 270 396 258"/>
          </g>
        </svg>
      SVG
    },
    "honey_fungus" => {
      name: "Honey Fungus",
      name_ro: "Ghebe",
      latin: "Armillaria mellea",
      description: "The autumn stump-dweller that fruits in golden clusters. Honey fungus erupts from tree bases and stumps after cool autumn rains, its dense bouquets glowing amber against dark bark.",
      description_ro: "Locuitorul de cioate al toamnei, care fructifică în ciorchini aurii. Ghebele erup de la baza copacilor și cioatelor după ploi reci de toamnă, buchetele lor dense strălucind chihlimbar pe scoarța întunecată.",
      season_months: [8, 9, 10, 11],
      temp_range: { ideal_min: 8, ideal_max: 18, abs_min: 3, abs_max: 24 },
      rain_range: { ideal_min: 15, ideal_max: 45, abs_min: 5, abs_max: 70 },
      delay_days: { ideal_min: 3, ideal_max: 7, abs_min: 1, abs_max: 10 },
      # Parasitic/saprotrophic — already colonized on wood substrate.
      # Responds quickly to autumn cooling after rain.
      temp_window: 5,
      # Peak is September–October when nights cool and autumn rains arrive.
      # August and November are secondary (early scouts and late stragglers).
      peak_months: [9, 10],
      # Parasitic on both deciduous and coniferous trees — needs living/dead wood.
      # Deciduous & mixed forests are ideal. Open grassland = no host trees.
      preferred_terrain: { ideal: ["deciduous", "mixed"], partial: ["coniferous", "park", "orchard", "scrubland"], bad: ["grassland", "farmland", "wetland", "water"] },
      tips: [
        "#{IconHelper.icon(:log)} Look at the base of living trees and on old stumps",
        "#{IconHelper.icon(:tree_deciduous)} Oak, beech, and birch forests are prime hunting grounds",
        "#{IconHelper.icon(:rain_heavy)} Best 3–7 days after steady autumn rains with cool nights",
        "#{IconHelper.icon(:sparkle)} They grow in dense clusters — where there's one, there are dozens",
        "#{IconHelper.icon(:fallen_leaf)} Check when leaves start falling and nights drop below 15°C",
        "#{IconHelper.icon(:checkmark)} Always verify the white ring on the stem — key safety feature",
        "#{IconHelper.icon(:amanita)} Beware look-alikes: Galerina marginata is deadly — check for ring and clustered growth"
      ],
      tips_ro: [
        "#{IconHelper.icon(:log)} Caută la baza copacilor vii și pe cioate vechi",
        "#{IconHelper.icon(:tree_deciduous)} Pădurile de stejar, fag și mesteacăn sunt locuri ideale",
        "#{IconHelper.icon(:rain_heavy)} Cel mai bine la 3–7 zile după ploi de toamnă cu nopți reci",
        "#{IconHelper.icon(:sparkle)} Cresc în ciorchini denși — unde e una, sunt zeci",
        "#{IconHelper.icon(:fallen_leaf)} Caută când cad frunzele și nopțile scad sub 15°C",
        "#{IconHelper.icon(:checkmark)} Verifică mereu inelul alb de pe picior — semn distinctiv de siguranță",
        "#{IconHelper.icon(:amanita)} Atenție la confuzii: Galerina marginata este mortală — verifică inelul și creșterea în ciorchini"
      ],
      color: "#C8A030",
      gradient_from: "#a88520",
      gradient_to: "#e8c860",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Armillaria_mellea_in_Sochi_14112015.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Opienka_miodowa_(Armillaria_mellea).JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Armillaria_mellea_opienka_miodowa_2.JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <!-- Soft autumn afternoon gradient -->
            <linearGradient id="honey-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#9aaa90"/>
              <stop offset="30%" stop-color="#8a9878"/>
              <stop offset="65%" stop-color="#708060"/>
              <stop offset="100%" stop-color="#5a6848"/>
            </linearGradient>
            <!-- Living tree trunk (not a stump — cluster grows from base) -->
            <linearGradient id="honey-trunk" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8a7858"/>
              <stop offset="35%" stop-color="#7a6848"/>
              <stop offset="70%" stop-color="#6a5838"/>
              <stop offset="100%" stop-color="#5a4828"/>
            </linearGradient>
            <!-- Warm golden cap with tawny-honey tones -->
            <linearGradient id="honey-cap" x1="0.2" y1="0" x2="0.8" y2="1">
              <stop offset="0%" stop-color="#e8c458"/>
              <stop offset="30%" stop-color="#d4a838"/>
              <stop offset="60%" stop-color="#c09028"/>
              <stop offset="100%" stop-color="#a87820"/>
            </linearGradient>
            <!-- Younger, brighter cap -->
            <linearGradient id="honey-cap2" x1="0.3" y1="0" x2="0.7" y2="1">
              <stop offset="0%" stop-color="#f0d068"/>
              <stop offset="50%" stop-color="#d8b040"/>
              <stop offset="100%" stop-color="#c09830"/>
            </linearGradient>
            <!-- Pale cream stem -->
            <linearGradient id="honey-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#c0b088"/>
              <stop offset="20%" stop-color="#ddd0b0"/>
              <stop offset="50%" stop-color="#e8dcc0"/>
              <stop offset="80%" stop-color="#d8c8a8"/>
              <stop offset="100%" stop-color="#b8a480"/>
            </linearGradient>
            <!-- Darker stem for background mushrooms -->
            <linearGradient id="honey-stem2" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#a89870"/>
              <stop offset="50%" stop-color="#c4b898"/>
              <stop offset="100%" stop-color="#a49068"/>
            </linearGradient>
            <!-- Gill undersurface -->
            <linearGradient id="honey-gill" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#f0e0b8"/>
              <stop offset="100%" stop-color="#c8a860"/>
            </linearGradient>
            <!-- Cap sheen -->
            <radialGradient id="honey-shine" cx="0.3" cy="0.25" r="0.5">
              <stop offset="0%" stop-color="#f8e070" stop-opacity="0.55"/>
              <stop offset="100%" stop-color="#c8a030" stop-opacity="0"/>
            </radialGradient>
            <!-- Atmospheric haze -->
            <linearGradient id="honey-haze" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8a9a80" stop-opacity="0"/>
              <stop offset="100%" stop-color="#8a9a80" stop-opacity="0.12"/>
            </linearGradient>
            <filter id="honey-shadow" x="-10%" y="-5%" width="120%" height="115%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="2"/>
              <feOffset dx="2" dy="3"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.12"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <!-- Background -->
          <rect width="400" height="300" fill="url(#honey-bg)"/>
          <!-- (background kept clean) -->
          <!-- Forest floor — leaf litter -->
          <ellipse cx="200" cy="288" rx="240" ry="25" fill="#4a4030" opacity="0.3"/>
          <ellipse cx="200" cy="283" rx="220" ry="18" fill="#5a5038" opacity="0.2"/>
          <!-- Scattered autumn leaves with veins -->
          <g opacity="0.45">
            <ellipse cx="42" cy="275" rx="15" ry="5" fill="#b86818" transform="rotate(-28 42 275)"/>
            <line x1="38" y1="276" x2="46" y2="274" stroke="#8a4810" stroke-width="0.4" opacity="0.5"/>
          </g>
          <ellipse cx="80" cy="270" rx="12" ry="4.5" fill="#c88028" opacity="0.35" transform="rotate(15 80 270)"/>
          <g opacity="0.38">
            <ellipse cx="340" cy="273" rx="16" ry="5" fill="#a85818" transform="rotate(20 340 273)"/>
            <line x1="336" y1="274" x2="344" y2="272" stroke="#804010" stroke-width="0.4" opacity="0.5"/>
          </g>
          <ellipse cx="360" cy="268" rx="10" ry="3.5" fill="#d09030" opacity="0.25" transform="rotate(-22 360 268)"/>
          <ellipse cx="120" cy="280" rx="13" ry="4" fill="#b07020" opacity="0.3" transform="rotate(32 120 280)"/>
          <ellipse cx="280" cy="278" rx="11" ry="3.5" fill="#c08828" opacity="0.28" transform="rotate(-12 280 278)"/>
          <!-- Tiny twigs on ground -->
          <line x1="55" y1="278" x2="100" y2="274" stroke="#5a4a30" stroke-width="1" opacity="0.2"/>
          <line x1="300" y1="276" x2="335" y2="272" stroke="#5a4a30" stroke-width="0.8" opacity="0.18"/>
          <!-- ══════ OAK TREE BASE ══════ -->
          <g>
            <!-- Trunk body — wide, slightly irregular -->
            <path d="M140 300 L136 240 Q134 215 140 195 Q148 180 160 170 Q168 164 176 166 L224 166 Q232 164 240 170 Q252 180 260 195 Q266 215 264 240 L260 300 Z" fill="url(#honey-trunk)"/>
            <!-- Bark texture — deep vertical cracks -->
            <path d="M155 170 Q153 210 155 250 Q156 275 155 298" stroke="#3a2810" stroke-width="2" fill="none" opacity="0.38"/>
            <path d="M170 168 Q168 210 170 250 Q171 278 170 298" stroke="#3a2810" stroke-width="1.4" fill="none" opacity="0.3"/>
            <path d="M186 167 Q185 210 186 250 Q186 278 186 300" stroke="#3a2810" stroke-width="1.1" fill="none" opacity="0.26"/>
            <path d="M200 167 Q201 210 200 252 Q200 278 200 300" stroke="#3a2810" stroke-width="1.1" fill="none" opacity="0.26"/>
            <path d="M214 167 Q215 210 214 250 Q214 278 214 300" stroke="#3a2810" stroke-width="1.1" fill="none" opacity="0.26"/>
            <path d="M230 168 Q232 210 230 250 Q229 278 230 298" stroke="#3a2810" stroke-width="1.4" fill="none" opacity="0.3"/>
            <path d="M245 170 Q247 210 245 250 Q244 275 245 298" stroke="#3a2810" stroke-width="2" fill="none" opacity="0.38"/>
            <!-- Horizontal bark plates -->
            <path d="M142 200 Q165 198 200 200 Q235 198 258 200" stroke="#3a2810" stroke-width="0.7" fill="none" opacity="0.2"/>
            <path d="M138 225 Q170 223 200 224 Q230 223 262 225" stroke="#3a2810" stroke-width="0.7" fill="none" opacity="0.18"/>
            <path d="M136 250 Q172 248 200 249 Q228 248 264 250" stroke="#3a2810" stroke-width="0.7" fill="none" opacity="0.18"/>
            <path d="M136 275 Q178 273 200 274 Q222 273 264 275" stroke="#3a2810" stroke-width="0.6" fill="none" opacity="0.15"/>
            <!-- Bark highlight (left light source) -->
            <path d="M148 180 Q146 210 148 250 Q149 275 148 295" stroke="#7a6a50" stroke-width="3" fill="none" opacity="0.12"/>
            <!-- Dark right edge -->
            <path d="M252 180 Q254 210 252 250 Q251 275 252 295" stroke="#3a2a15" stroke-width="2.5" fill="none" opacity="0.15"/>

            <!-- ── Branch stubs ── -->
            <!-- Left stub (broken short, angled up-left) -->
            <path d="M140 195 Q126 186 116 178" stroke="#4a3820" stroke-width="8" stroke-linecap="round" fill="none"/>
            <path d="M140 195 Q126 186 116 178" stroke="#5a4830" stroke-width="4.5" stroke-linecap="round" fill="none"/>
            <path d="M116 178 L112 172 L118 175" fill="#4a3820" opacity="0.5"/>

            <!-- Right stub (shorter, angled up-right) -->
            <path d="M260 200 Q274 192 282 186" stroke="#4a3820" stroke-width="6.5" stroke-linecap="round" fill="none"/>
            <path d="M260 200 Q274 192 282 186" stroke="#5a4830" stroke-width="3.5" stroke-linecap="round" fill="none"/>

            <!-- Lower left twig stub -->
            <path d="M138 240 Q126 234 120 228" stroke="#4a3820" stroke-width="4.5" stroke-linecap="round" fill="none"/>
            <path d="M138 240 Q126 234 120 228" stroke="#5a4830" stroke-width="2.2" stroke-linecap="round" fill="none"/>

            <!-- Root flare at base -->
            <path d="M136 290 Q120 286 108 290 Q100 296 98 300 L140 300 Z" fill="#6a5838" opacity="0.5"/>
            <path d="M264 290 Q280 286 292 290 Q300 296 302 300 L260 300 Z" fill="#5a4828" opacity="0.45"/>

            <!-- Moss patches on trunk (north-facing left side) -->
            <ellipse cx="145" cy="260" rx="7" ry="16" fill="#5a8a3a" opacity="0.22"/>
            <ellipse cx="148" cy="286" rx="9" ry="10" fill="#6a9a4a" opacity="0.2"/>
            <ellipse cx="142" cy="215" rx="5" ry="9" fill="#4a7a2a" opacity="0.16"/>
            <!-- Lichen spots -->
            <circle cx="238" cy="235" r="5" fill="#8a9a6a" opacity="0.14"/>
            <circle cx="168" cy="190" r="3.5" fill="#8a9a6a" opacity="0.11"/>
            <circle cx="248" cy="270" r="4" fill="#8a9a6a" opacity="0.1"/>
          </g>
          <!-- ══════ MUSHROOM CLUSTER — arching bouquet from one point ══════ -->
          <!-- All stems originate from trunk ~x200 y260, arcing outward -->
          <g filter="url(#honey-shadow)">
            <!-- ── Back row (4 small, arcing outward, partially hidden) ── -->
            <!-- Back 1: arcs hard left -->
            <path d="M192 258 Q180 248 164 230 Q158 222 155 216 L160 213 Q163 220 170 230 Q183 244 196 254 Z" fill="url(#honey-stem2)"/>
            <path d="M147 218 Q145 213 147 208 Q151 203 155 201 Q159 203 161 207 Q163 212 161 217 Q156 220 150 219 Z" fill="url(#honey-cap)" opacity="0.8"/>
            <ellipse cx="168" cy="236" rx="4" ry="1.8" fill="#f0e8d0" opacity="0.4" stroke="#c8b890" stroke-width="0.3" transform="rotate(-35 168 236)"/>

            <!-- Back 2: arcs moderate left -->
            <path d="M196 258 Q188 245 180 226 Q176 216 175 210 L180 208 Q182 214 186 224 Q194 242 200 254 Z" fill="url(#honey-stem2)"/>
            <path d="M168 212 Q166 206 168 200 Q172 194 178 192 Q183 194 186 199 Q188 205 186 211 Q180 215 173 214 Z" fill="url(#honey-cap)"/>
            <path d="M170 208 Q170 204 172 200 Q174 196 178 194 Q177 198 176 202 Q175 206 175 208 Z" fill="url(#honey-shine)" opacity="0.35"/>
            <ellipse cx="183" cy="220" rx="5" ry="1.8" fill="#f0e8d0" opacity="0.45" stroke="#c8b890" stroke-width="0.3" transform="rotate(-20 183 220)"/>

            <!-- Back 3: arcs moderate right -->
            <path d="M204 258 Q212 245 220 226 Q224 216 225 210 L220 208 Q218 214 214 224 Q206 242 200 254 Z" fill="url(#honey-stem2)"/>
            <path d="M232 212 Q234 206 232 200 Q228 194 222 192 Q217 194 214 199 Q212 205 214 211 Q220 215 227 214 Z" fill="url(#honey-cap)"/>
            <path d="M230 208 Q230 204 228 200 Q226 196 222 194 Q223 198 224 202 Q225 206 225 208 Z" fill="url(#honey-shine)" opacity="0.35"/>
            <ellipse cx="217" cy="220" rx="5" ry="1.8" fill="#f0e8d0" opacity="0.45" stroke="#c8b890" stroke-width="0.3" transform="rotate(20 217 220)"/>

            <!-- Back 4: arcs hard right -->
            <path d="M208 258 Q220 248 236 230 Q242 222 245 216 L240 213 Q237 220 230 230 Q217 244 204 254 Z" fill="url(#honey-stem2)"/>
            <path d="M253 218 Q255 213 253 208 Q249 203 245 201 Q241 203 239 207 Q237 212 239 217 Q244 220 250 219 Z" fill="url(#honey-cap)" opacity="0.8"/>
            <ellipse cx="232" cy="236" rx="4" ry="1.8" fill="#f0e8d0" opacity="0.4" stroke="#c8b890" stroke-width="0.3" transform="rotate(35 232 236)"/>

            <!-- ── Hero row: 3 mushrooms, arcing outward like a fan ── -->

            <!-- Hero LEFT — arcs left -->
            <path d="M194 262 Q182 252 164 228 Q157 218 154 210 L160 206 Q164 214 172 228 Q186 248 198 258 Z" fill="url(#honey-stem)"/>
            <g stroke="#b0a070" fill="none" opacity="0.25">
              <path d="M196 260 Q185 250 168 228 Q162 220 159 212" stroke-width="0.5"/>
            </g>
            <!-- Cap ~45px wide -->
            <path d="M136 214 Q134 206 138 196 Q144 186 155 182 Q163 180 171 184 Q180 188 184 198 Q186 204 184 212 Q176 218 160 219 Q142 218 136 214 Z" fill="url(#honey-cap)"/>
            <ellipse cx="158" cy="190" rx="5" ry="3" fill="#b89028" opacity="0.25" transform="rotate(-8 158 190)"/>
            <path d="M142 210 Q140 204 144 196 Q148 190 155 186 Q154 190 152 196 Q150 204 148 210 Z" fill="url(#honey-shine)" opacity="0.45"/>
            <g fill="#8a6818" opacity="0.34">
              <ellipse cx="154" cy="188" rx="1.6" ry="0.8" transform="rotate(-8 154 188)"/>
              <ellipse cx="162" cy="186" rx="1.4" ry="0.7" transform="rotate(-2 162 186)"/>
              <ellipse cx="146" cy="194" rx="1.5" ry="0.7" transform="rotate(-14 146 194)"/>
              <ellipse cx="156" cy="193" rx="1.3" ry="0.7" transform="rotate(-4 156 193)"/>
              <ellipse cx="166" cy="194" rx="1.2" ry="0.6" transform="rotate(6 166 194)"/>
              <ellipse cx="142" cy="202" rx="1.2" ry="0.6" transform="rotate(-16 142 202)"/>
              <ellipse cx="154" cy="200" rx="1.1" ry="0.6" transform="rotate(-6 154 200)"/>
              <ellipse cx="166" cy="200" rx="1" ry="0.5" transform="rotate(4 166 200)"/>
              <ellipse cx="176" cy="202" rx="0.9" ry="0.5" transform="rotate(10 176 202)"/>
            </g>
            <path d="M173 185 Q181 190 184 200 Q186 206 184 212 L180 214 Q181 206 178 200 Q176 192 173 185 Z" fill="#705010" opacity="0.12"/>
            <path d="M136 214 Q142 218 160 219 Q176 218 184 212 Q178 216 160 217 Q142 216 136 214 Z" fill="#806018" opacity="0.16"/>
            <g stroke="#c8a848" stroke-width="0.5" fill="none" opacity="0.38">
              <path d="M140 214 L148 208 L158 214"/>
              <path d="M158 214 L168 208 L178 212"/>
            </g>
            <ellipse cx="168" cy="228" rx="7" ry="2.8" fill="#ede6d0" stroke="#c8c0a0" stroke-width="0.5" transform="rotate(-35 168 228)"/>

            <!-- Hero CENTER — nearly vertical, tallest -->
            <path d="M197 262 Q195 248 196 224 Q197 214 200 206 L209 206 Q212 214 213 224 Q214 248 212 262 Z" fill="url(#honey-stem)"/>
            <g stroke="#b0a070" fill="none" opacity="0.25">
              <path d="M201 258 Q201 238 202 214" stroke-width="0.5"/>
              <path d="M208 258 Q209 238 208 214" stroke-width="0.5"/>
            </g>
            <path d="M197 262 Q196 256 197 250 L212 250 Q213 256 212 262 Z" fill="#706038" opacity="0.15"/>
            <!-- Cap ~48px wide -->
            <path d="M188 214 Q186 204 190 192 Q196 180 206 176 Q214 174 222 178 Q232 184 236 194 Q239 204 236 214 Q228 222 212 223 Q194 222 188 214 Z" fill="url(#honey-cap2)"/>
            <ellipse cx="212" cy="184" rx="6" ry="3.5" fill="#c09830" opacity="0.24"/>
            <path d="M194 210 Q192 204 196 194 Q200 186 206 180 Q204 186 202 194 Q200 202 198 210 Z" fill="url(#honey-shine)" opacity="0.45"/>
            <g fill="#907020" opacity="0.34">
              <ellipse cx="208" cy="183" rx="1.6" ry="0.8"/>
              <ellipse cx="216" cy="182" rx="1.4" ry="0.7" transform="rotate(4 216 182)"/>
              <ellipse cx="200" cy="190" rx="1.4" ry="0.7" transform="rotate(-6 200 190)"/>
              <ellipse cx="212" cy="188" rx="1.2" ry="0.7"/>
              <ellipse cx="222" cy="190" rx="1.1" ry="0.6" transform="rotate(6 222 190)"/>
              <ellipse cx="196" cy="198" rx="1.2" ry="0.6" transform="rotate(-10 196 198)"/>
              <ellipse cx="206" cy="196" rx="1.1" ry="0.6"/>
              <ellipse cx="218" cy="196" rx="1.1" ry="0.6" transform="rotate(4 218 196)"/>
              <ellipse cx="228" cy="198" rx="1" ry="0.5" transform="rotate(8 228 198)"/>
            </g>
            <path d="M226 180 Q234 186 236 196 Q239 204 236 214 L232 216 Q234 206 232 198 Q228 188 226 180 Z" fill="#705010" opacity="0.11"/>
            <path d="M188 214 Q194 222 212 223 Q228 222 236 214 Q230 218 212 220 Q196 218 188 214 Z" fill="#806018" opacity="0.15"/>
            <g stroke="#c8a848" stroke-width="0.55" fill="none" opacity="0.42">
              <path d="M192 214 L200 208 L212 214"/>
              <path d="M212 214 L222 208 L232 212"/>
            </g>
            <ellipse cx="205" cy="226" rx="9" ry="3" fill="#ede6d0" stroke="#c8c0a0" stroke-width="0.5"/>
            <path d="M196 226 Q200 229 205 230 Q210 229 214 226" fill="#e8e0c8" stroke="#c0b898" stroke-width="0.3" opacity="0.45"/>

            <!-- Hero RIGHT — arcs right -->
            <path d="M206 262 Q218 252 236 228 Q243 218 246 210 L240 206 Q236 214 228 228 Q214 248 202 258 Z" fill="url(#honey-stem)"/>
            <g stroke="#b0a070" fill="none" opacity="0.25">
              <path d="M204 260 Q215 250 232 228 Q238 220 241 212" stroke-width="0.5"/>
            </g>
            <!-- Cap ~45px wide -->
            <path d="M242 214 Q240 206 244 196 Q250 186 261 182 Q269 180 277 184 Q286 188 290 198 Q292 204 290 212 Q282 218 266 219 Q248 218 242 214 Z" fill="url(#honey-cap2)"/>
            <ellipse cx="264" cy="190" rx="5" ry="3" fill="#c09830" opacity="0.24" transform="rotate(8 264 190)"/>
            <path d="M250 210 Q248 204 252 196 Q256 190 261 186 Q260 190 258 196 Q256 204 254 210 Z" fill="url(#honey-shine)" opacity="0.42"/>
            <g fill="#907020" opacity="0.32">
              <ellipse cx="262" cy="188" rx="1.6" ry="0.8" transform="rotate(6 262 188)"/>
              <ellipse cx="270" cy="186" rx="1.4" ry="0.7" transform="rotate(10 270 186)"/>
              <ellipse cx="254" cy="194" rx="1.5" ry="0.7" transform="rotate(-4 254 194)"/>
              <ellipse cx="264" cy="193" rx="1.3" ry="0.7" transform="rotate(4 264 193)"/>
              <ellipse cx="274" cy="194" rx="1.1" ry="0.6" transform="rotate(12 274 194)"/>
              <ellipse cx="250" cy="202" rx="1.2" ry="0.6" transform="rotate(-8 250 202)"/>
              <ellipse cx="262" cy="200" rx="1.1" ry="0.6"/>
              <ellipse cx="274" cy="200" rx="1" ry="0.5" transform="rotate(8 274 200)"/>
              <ellipse cx="284" cy="202" rx="0.9" ry="0.5" transform="rotate(14 284 202)"/>
            </g>
            <path d="M279 185 Q287 190 290 200 Q292 206 290 212 L286 214 Q287 206 284 200 Q282 192 279 185 Z" fill="#705010" opacity="0.11"/>
            <path d="M242 214 Q248 218 266 219 Q282 218 290 212 Q284 216 266 217 Q250 216 242 214 Z" fill="#806018" opacity="0.15"/>
            <g stroke="#c8a848" stroke-width="0.5" fill="none" opacity="0.38">
              <path d="M246 214 L254 208 L264 214"/>
              <path d="M264 214 L274 208 L284 212"/>
            </g>
            <ellipse cx="238" cy="228" rx="7" ry="2.8" fill="#ede6d0" stroke="#c8c0a0" stroke-width="0.5" transform="rotate(35 238 228)"/>

            <!-- ── Front row: 2 medium mushrooms in front of heroes ── -->

            <!-- Front LEFT — arcs moderately left, shorter stem -->
            <path d="M195 264 Q186 256 172 240 Q166 232 164 226 L170 223 Q173 229 178 238 Q190 252 198 261 Z" fill="url(#honey-stem)"/>
            <g stroke="#b0a070" fill="none" opacity="0.22">
              <path d="M196 262 Q188 254 176 240 Q172 234 170 228" stroke-width="0.4"/>
            </g>
            <!-- Cap ~38px wide -->
            <path d="M148 230 Q146 224 150 216 Q155 208 164 204 Q170 203 177 206 Q184 210 188 218 Q190 224 188 230 Q180 236 168 236 Q152 236 148 230 Z" fill="url(#honey-cap)"/>
            <ellipse cx="166" cy="212" rx="4" ry="2.5" fill="#b89028" opacity="0.22" transform="rotate(-8 166 212)"/>
            <path d="M153 226 Q152 222 154 216 Q158 210 164 208 Q162 212 160 218 Q158 224 157 226 Z" fill="url(#honey-shine)" opacity="0.4"/>
            <g fill="#8a6818" opacity="0.32">
              <ellipse cx="163" cy="210" rx="1.3" ry="0.6" transform="rotate(-8 163 210)"/>
              <ellipse cx="170" cy="209" rx="1.1" ry="0.6" transform="rotate(-2 170 209)"/>
              <ellipse cx="158" cy="216" rx="1.2" ry="0.6" transform="rotate(-12 158 216)"/>
              <ellipse cx="167" cy="215" rx="1" ry="0.5"/>
              <ellipse cx="175" cy="216" rx="0.9" ry="0.5" transform="rotate(6 175 216)"/>
              <ellipse cx="155" cy="222" rx="1" ry="0.5" transform="rotate(-14 155 222)"/>
              <ellipse cx="166" cy="221" rx="0.9" ry="0.5"/>
              <ellipse cx="178" cy="222" rx="0.8" ry="0.4" transform="rotate(8 178 222)"/>
            </g>
            <path d="M148 230 Q152 236 168 236 Q180 236 188 230 Q182 234 168 234 Q154 234 148 230 Z" fill="#806018" opacity="0.14"/>
            <g stroke="#c8a848" stroke-width="0.45" fill="none" opacity="0.35">
              <path d="M152 230 L160 224 L168 230"/>
              <path d="M168 230 L176 224 L184 228"/>
            </g>
            <ellipse cx="174" cy="240" rx="6" ry="2.4" fill="#ede6d0" stroke="#c8b890" stroke-width="0.4" transform="rotate(-28 174 240)"/>

            <!-- Front RIGHT — arcs moderately right, shorter stem -->
            <path d="M209 264 Q218 256 232 240 Q238 232 240 226 L234 223 Q231 229 226 238 Q214 252 206 261 Z" fill="url(#honey-stem)"/>
            <g stroke="#b0a070" fill="none" opacity="0.22">
              <path d="M208 262 Q216 254 228 240 Q232 234 234 228" stroke-width="0.4"/>
            </g>
            <!-- Cap ~38px wide -->
            <path d="M220 230 Q218 224 222 216 Q227 208 236 204 Q242 203 249 206 Q256 210 260 218 Q262 224 260 230 Q252 236 240 236 Q224 236 220 230 Z" fill="url(#honey-cap2)"/>
            <ellipse cx="238" cy="212" rx="4" ry="2.5" fill="#c09830" opacity="0.22" transform="rotate(8 238 212)"/>
            <path d="M227 226 Q226 222 228 216 Q232 210 236 208 Q235 212 234 218 Q232 224 231 226 Z" fill="url(#honey-shine)" opacity="0.4"/>
            <g fill="#8a6818" opacity="0.32">
              <ellipse cx="237" cy="210" rx="1.3" ry="0.6" transform="rotate(8 237 210)"/>
              <ellipse cx="244" cy="209" rx="1.1" ry="0.6" transform="rotate(2 244 209)"/>
              <ellipse cx="232" cy="216" rx="1.2" ry="0.6" transform="rotate(-4 232 216)"/>
              <ellipse cx="240" cy="215" rx="1" ry="0.5"/>
              <ellipse cx="248" cy="216" rx="0.9" ry="0.5" transform="rotate(10 248 216)"/>
              <ellipse cx="228" cy="222" rx="1" ry="0.5" transform="rotate(-6 228 222)"/>
              <ellipse cx="240" cy="221" rx="0.9" ry="0.5"/>
              <ellipse cx="252" cy="222" rx="0.8" ry="0.4" transform="rotate(12 252 222)"/>
            </g>
            <path d="M220 230 Q224 236 240 236 Q252 236 260 230 Q254 234 240 234 Q226 234 220 230 Z" fill="#806018" opacity="0.14"/>
            <g stroke="#c8a848" stroke-width="0.45" fill="none" opacity="0.35">
              <path d="M224 230 L232 224 L240 230"/>
              <path d="M240 230 L248 224 L256 228"/>
            </g>
            <ellipse cx="230" cy="240" rx="6" ry="2.4" fill="#ede6d0" stroke="#c8b890" stroke-width="0.4" transform="rotate(28 230 240)"/>

            <!-- ── Baby mushrooms arcing outward (6 babies) ── -->
            <!-- Baby far-left -->
            <path d="M193 264 Q186 260 178 252 Q174 246 172 242 L176 240 Q178 244 182 250 Q190 258 196 262 Z" fill="url(#honey-stem2)"/>
            <ellipse cx="172" cy="240" rx="4.5" ry="3" fill="url(#honey-cap2)" transform="rotate(-25 172 240)"/>
            <ellipse cx="171" cy="239" rx="1.8" ry="1" fill="#f0d868" opacity="0.25" transform="rotate(-25 171 239)"/>

            <!-- Baby center-left -->
            <path d="M196 264 Q193 260 188 250 Q186 246 186 242 L190 240 Q190 244 192 248 Q196 256 199 262 Z" fill="url(#honey-stem2)"/>
            <path d="M183 244 Q182 240 184 236 Q187 232 191 231 Q194 233 196 237 Q197 241 195 244 Z" fill="url(#honey-cap2)"/>

            <!-- Baby inner-left -->
            <path d="M199 264 Q198 260 196 254 Q195 250 195 247 L199 246 Q199 249 200 254 Q201 258 202 263 Z" fill="url(#honey-stem2)"/>
            <path d="M192 249 Q191 245 193 242 Q196 239 199 238 Q201 240 202 243 Q203 247 201 249 Z" fill="url(#honey-cap2)"/>

            <!-- Baby inner-right -->
            <path d="M205 264 Q206 260 208 254 Q209 250 209 247 L205 246 Q205 249 204 254 Q203 258 202 263 Z" fill="url(#honey-stem2)"/>
            <path d="M212 249 Q213 245 211 242 Q208 239 205 238 Q203 240 202 243 Q201 247 203 249 Z" fill="url(#honey-cap2)"/>

            <!-- Baby center-right -->
            <path d="M208 264 Q211 260 216 250 Q218 246 218 242 L214 240 Q214 244 212 248 Q208 256 205 262 Z" fill="url(#honey-stem2)"/>
            <path d="M221 244 Q222 240 220 236 Q217 232 213 231 Q210 233 208 237 Q207 241 209 244 Z" fill="url(#honey-cap2)"/>

            <!-- Baby far-right -->
            <path d="M211 264 Q218 260 226 252 Q230 246 232 242 L228 240 Q226 244 222 250 Q214 258 208 262 Z" fill="url(#honey-stem2)"/>
            <ellipse cx="232" cy="240" rx="4.5" ry="3" fill="url(#honey-cap2)" transform="rotate(25 232 240)"/>
            <ellipse cx="233" cy="239" rx="1.8" ry="1" fill="#f0d868" opacity="0.25" transform="rotate(25 233 239)"/>
          </g>
          <!-- ══════ RHIZOMORPHS (dark bootlaces on bark) ══════ -->
          <g stroke="#1a1008" fill="none" opacity="0.28">
            <path d="M140 265 Q128 262 118 268 Q110 278 106 292" stroke-width="2.2"/>
            <path d="M142 280 Q132 278 124 284 Q118 292 116 300" stroke-width="1.6"/>
            <path d="M260 268 Q272 265 282 272 Q290 282 294 296" stroke-width="2"/>
            <path d="M258 282 Q268 280 276 286 Q282 294 286 300" stroke-width="1.4"/>
          </g>
          <!-- (haze removed for clarity) -->
          <!-- Grass tufts -->
          <g opacity="0.3" fill="none">
            <path d="M90 285 Q92 273 88 264" stroke="#3a6828" stroke-width="1.3"/>
            <path d="M94 285 Q95 274 98 265" stroke="#4a7838" stroke-width="1.1"/>
            <path d="M310 284 Q308 273 312 264" stroke="#3a6828" stroke-width="1.2"/>
            <path d="M314 284 Q316 275 313 266" stroke="#4a7838" stroke-width="1"/>
          </g>
        </svg>
      SVG
    },
    "chicken_of_the_woods" => {
      name: "Chicken of the Woods",
      name_ro: "Iasca galbenă",
      latin: "Laetiporus sulphureus",
      description: "Brilliant orange-yellow shelves erupt from oak and chestnut trunks in warm early summer. This meaty bracket fungus returns to the same tree year after year, rewarding foragers who mark their finds.",
      description_ro: "Rafturi strălucitor portocaliu-aurii erup din trunchiuri de stejar și castan în vara timpurie. Acest burete cărnos revine la același copac an de an, răsplătind culegătorii care își marchează descoperirile.",
      season_months: [4, 5, 6, 7, 8, 9, 10],
      temp_range: { ideal_min: 15, ideal_max: 25, abs_min: 10, abs_max: 30 },
      rain_range: { ideal_min: 5, ideal_max: 15, abs_min: 2, abs_max: 25 },
      delay_days: { ideal_min: 3, ideal_max: 7, abs_min: 2, abs_max: 14 },
      # Bracket fungus on wood — responds to warmth + humidity rather than soil moisture.
      # 5-day temp average captures the warm spell that triggers fruiting.
      temp_window: 5,
      # Grows on hardwood trees — needs deciduous or mixed forest with mature trees.
      preferred_terrain: { ideal: ["deciduous", "orchard", "park"], partial: ["mixed", "scrubland"], bad: ["coniferous", "grassland", "farmland", "wetland", "water"] },
      tips: [
        "#{IconHelper.icon(:map_pin)} Mark the tree — chicken of the woods returns to the same host yearly",
        "#{IconHelper.icon(:tree_deciduous)} Check mature oak, chestnut, and cherry trees especially",
        "#{IconHelper.icon(:hand_pick)} Harvest young, bright-orange shelves — older pale ones get tough",
        "#{IconHelper.icon(:storm)} Best 3-7 days after warm rain following dry spells",
        "#{IconHelper.icon(:sunrise)} Morning harvest gives firmest, freshest texture",
        "#{IconHelper.icon(:sun)} Yellow pores underneath confirm ID — never white gills",
        "#{IconHelper.icon(:log)} Dead standing trunks and large fallen logs are prime spots"
      ],
      tips_ro: [
        "#{IconHelper.icon(:map_pin)} Marchează copacul — buretele sulfuros revine la aceeași gazdă anual",
        "#{IconHelper.icon(:tree_deciduous)} Verifică stejarii, castanii și cireșii maturi în special",
        "#{IconHelper.icon(:hand_pick)} Recoltează rafturile tinere, portocaliu-intens — cele vechi devin tari",
        "#{IconHelper.icon(:storm)} Cel mai bine la 3-7 zile după ploaie caldă după secetă",
        "#{IconHelper.icon(:sunrise)} Recolta dimineață oferă textura cea mai fermă și proaspătă",
        "#{IconHelper.icon(:sun)} Porii galbeni dedesubt confirmă identificarea — niciodată lamele albe",
        "#{IconHelper.icon(:log)} Trunchiurile moarte în picioare și buștenii mari căzuți sunt locuri ideale"
      ],
      color: "#FF8C00",
      gradient_from: "#FFB347",
      gradient_to: "#FF6600",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Chicken_of_the_Woods_-_Laetiporus_sulphureus.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Laetiporus_sulphureus_(Chicken_of_the_woods)_on_an_oak_tree_-_20070921.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Yellow-orange_coloured_Laetiporus_sulphureus_(Chicken_of_the_Woods_or_Sulphur_shelf,_D%3D_Schwefelporling,_F%3D_Polypore_soufr%C3%A9,_NL%3D_Zwavelzwam)_white_spores_and_causes_brown_rot,_at_these_old_trunk_at_Schaarsbergen_forest_-_panoramio.jpg?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="cotw-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8a9a70"/>
              <stop offset="40%" stop-color="#728860"/>
              <stop offset="70%" stop-color="#5a6848"/>
              <stop offset="100%" stop-color="#4a4030"/>
            </linearGradient>
            <linearGradient id="cotw-trunk" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#4a3525"/>
              <stop offset="20%" stop-color="#6a4a35"/>
              <stop offset="50%" stop-color="#7a5a42"/>
              <stop offset="80%" stop-color="#684838"/>
              <stop offset="100%" stop-color="#4a3020"/>
            </linearGradient>
            <!-- Main shelf gradient: bright sulphur-yellow at base → rich orange at outer edge -->
            <radialGradient id="cotw-shelf1" cx="0.15" cy="0.4" r="0.9">
              <stop offset="0%" stop-color="#FFE44D"/>
              <stop offset="30%" stop-color="#FFD020"/>
              <stop offset="55%" stop-color="#FFA820"/>
              <stop offset="80%" stop-color="#FF7A10"/>
              <stop offset="100%" stop-color="#E85800"/>
            </radialGradient>
            <radialGradient id="cotw-shelf2" cx="0.2" cy="0.35" r="0.85">
              <stop offset="0%" stop-color="#FFDD40"/>
              <stop offset="35%" stop-color="#FFC018"/>
              <stop offset="60%" stop-color="#FF9A18"/>
              <stop offset="85%" stop-color="#FF6A08"/>
              <stop offset="100%" stop-color="#D84A00"/>
            </radialGradient>
            <radialGradient id="cotw-shelf3" cx="0.25" cy="0.4" r="0.8">
              <stop offset="0%" stop-color="#FFE860"/>
              <stop offset="30%" stop-color="#FFD530"/>
              <stop offset="60%" stop-color="#FFB020"/>
              <stop offset="100%" stop-color="#FF6600"/>
            </radialGradient>
            <!-- Underside (pore surface) — pale sulphur yellow -->
            <linearGradient id="cotw-pores" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#FFE880"/>
              <stop offset="100%" stop-color="#FFCC40"/>
            </linearGradient>
            <radialGradient id="cotw-dapple" cx="0.5" cy="0.5" r="0.5">
              <stop offset="0%" stop-color="#b8c8a0" stop-opacity="0.15"/>
              <stop offset="100%" stop-color="#b8c8a0" stop-opacity="0"/>
            </radialGradient>
            <filter id="cotw-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.18"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#cotw-bg)"/>
          <!-- Dappled light -->
          <ellipse cx="100" cy="50" rx="50" ry="35" fill="url(#cotw-dapple)"/>
          <ellipse cx="320" cy="60" rx="40" ry="28" fill="url(#cotw-dapple)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="286" rx="230" ry="28" fill="#4a4030" opacity="0.25"/>
          <!-- ===== OAK TRUNK — thick, textured, characterful ===== -->
          <!-- Trunk body -->
          <path d="M150 0 Q148 50 146 150 Q145 220 148 300 L252 300 Q255 220 254 150 Q252 50 250 0 Z" fill="url(#cotw-trunk)"/>
          <!-- Trunk roundness highlights -->
          <path d="M165 0 Q163 80 162 160 Q161 240 163 300 L195 300 Q193 240 192 160 Q191 80 193 0 Z" fill="#8a6a4a" opacity="0.15"/>
          <!-- Deep bark furrows -->
          <g stroke="#3a2518" fill="none" opacity="0.3">
            <path d="M160 15 Q162 40 158 65 Q156 90 160 115 Q163 140 159 165 Q157 190 161 215 Q164 240 160 265 Q158 280 160 300" stroke-width="1.2"/>
            <path d="M178 10 Q180 35 176 60 Q174 85 178 110 Q181 135 177 160 Q175 185 179 210 Q182 235 178 260 Q176 280 178 300" stroke-width="1"/>
            <path d="M200 8 Q198 40 202 70 Q204 100 200 130 Q198 160 202 190 Q204 220 200 250 Q198 275 200 300" stroke-width="0.8"/>
            <path d="M220 12 Q222 40 218 68 Q216 95 220 122 Q223 150 219 178 Q217 205 221 232 Q224 260 220 288" stroke-width="1"/>
            <path d="M238 18 Q236 45 240 72 Q242 98 238 125 Q236 152 240 180 Q242 208 238 235 Q236 262 238 290" stroke-width="1.1"/>
          </g>
          <!-- Bark ridges (horizontal texture) -->
          <g stroke="#5a4030" fill="none" opacity="0.15">
            <path d="M155 50 Q180 48 200 50 Q220 52 245 48" stroke-width="0.6"/>
            <path d="M153 100 Q180 97 200 100 Q225 102 248 98" stroke-width="0.5"/>
            <path d="M150 180 Q175 177 200 180 Q225 183 250 178" stroke-width="0.6"/>
            <path d="M150 230 Q178 228 200 230 Q225 232 252 228" stroke-width="0.5"/>
          </g>
          <!-- ===== BRACKET SHELVES — realistic fan shapes with wavy edges ===== -->
          <g filter="url(#cotw-shadow)">
            <!-- === SHELF A (large, hero, right side, mid-trunk) === -->
            <!-- Pore surface underside (visible as thickness) -->
            <path d="M248 140 Q268 138 290 142 Q308 148 318 156 Q305 160 285 158 Q265 154 248 148 Z" fill="url(#cotw-pores)" opacity="0.7"/>
            <!-- Main shelf top — fan/kidney shape with wavy lobed edge -->
            <path d="M248 130 Q250 126 260 122 Q275 118 292 120
                     Q308 124 316 132 Q320 138 318 142
                     Q314 146 305 148 Q292 150 276 148
                     Q260 144 248 138 Z" fill="url(#cotw-shelf1)"/>
            <!-- Concentric growth zones (rings like real brackets) -->
            <g stroke="#D87800" fill="none" opacity="0.25">
              <path d="M255 128 Q268 124 286 126 Q302 130 312 136" stroke-width="0.7"/>
              <path d="M258 132 Q270 128 284 130 Q298 134 306 138" stroke-width="0.6"/>
              <path d="M260 136 Q272 133 284 134 Q295 137 302 140" stroke-width="0.5"/>
            </g>
            <!-- Wavy edge detail -->
            <path d="M260 122 Q268 119 278 118 Q288 119 298 122 Q306 126 312 132 Q316 137 318 142"
                  stroke="#D05000" stroke-width="0.8" fill="none" opacity="0.35"/>
            <!-- Surface highlight (wet sheen) -->
            <path d="M258 126 Q270 122 284 123 Q296 126 306 132" fill="#FFE860" opacity="0.15"/>

            <!-- === SHELF B (largest, hero, right side, lower) === -->
            <path d="M246 172 Q265 170 290 174 Q312 182 328 194 Q315 200 292 198 Q268 192 250 184 Z" fill="url(#cotw-pores)" opacity="0.65"/>
            <path d="M246 160 Q250 154 262 148 Q280 144 300 146
                     Q318 150 328 162 Q334 170 332 178
                     Q326 184 314 186 Q296 188 278 184
                     Q260 178 252 170 Q246 166 246 160 Z" fill="url(#cotw-shelf2)"/>
            <!-- Growth zones -->
            <g stroke="#D07000" fill="none" opacity="0.25">
              <path d="M258 154 Q275 148 295 150 Q314 156 325 166" stroke-width="0.8"/>
              <path d="M262 160 Q278 155 292 156 Q310 162 320 170" stroke-width="0.7"/>
              <path d="M266 166 Q280 162 292 163 Q306 168 316 174" stroke-width="0.6"/>
              <path d="M268 170 Q282 167 292 168 Q304 172 312 178" stroke-width="0.5"/>
            </g>
            <!-- Wavy lobed edge -->
            <path d="M265 148 Q280 144 295 144 Q310 146 320 154 Q328 162 332 172 Q334 178 332 178"
                  stroke="#C04800" stroke-width="0.9" fill="none" opacity="0.3"/>
            <!-- Surface highlight -->
            <path d="M265 154 Q282 148 298 150 Q315 155 325 164" fill="#FFE860" opacity="0.12"/>

            <!-- === SHELF C (small, top, right side) === -->
            <path d="M245 88 Q255 82 270 80 Q288 82 300 90
                     Q306 96 304 100 Q298 104 285 104
                     Q270 102 255 96 Q248 92 245 88 Z" fill="url(#cotw-shelf3)"/>
            <g stroke="#D07800" fill="none" opacity="0.22">
              <path d="M254 86 Q268 82 282 84 Q294 88 300 94" stroke-width="0.6"/>
              <path d="M257 90 Q268 87 280 88 Q290 91 296 96" stroke-width="0.5"/>
            </g>
            <path d="M258 82 Q272 80 286 82 Q296 86 302 92" fill="#FFE860" opacity="0.12"/>

            <!-- === SHELF D (left side, medium, overlapping trunk) === -->
            <path d="M152 156 Q140 160 124 162 Q110 160 104 154 Q108 148 118 146 Q132 145 148 150 Z" fill="url(#cotw-pores)" opacity="0.6"/>
            <path d="M152 145 Q148 140 138 136 Q122 134 108 138
                     Q98 144 96 150 Q100 156 110 158
                     Q124 158 138 154 Q150 150 152 145 Z" fill="url(#cotw-shelf1)"/>
            <g stroke="#D07800" fill="none" opacity="0.2">
              <path d="M144 140 Q130 137 116 139 Q106 143 102 148" stroke-width="0.6"/>
              <path d="M142 144 Q130 142 118 143 Q108 146 104 150" stroke-width="0.5"/>
            </g>

            <!-- === SHELF E (tiny, left side, upper) === -->
            <path d="M154 108 Q146 104 136 104 Q126 106 122 112
                     Q126 116 134 116 Q144 114 152 112 Z" fill="url(#cotw-shelf3)"/>
            <path d="M148 106 Q138 104 130 106 Q126 110 128 114" stroke="#D07800" stroke-width="0.4" fill="none" opacity="0.2"/>
          </g>
          <!-- Moss on trunk base -->
          <g opacity="0.45">
            <circle cx="165" cy="275" r="7" fill="#3a7a1a"/>
            <circle cx="175" cy="270" r="5" fill="#4a8a2a"/>
            <circle cx="155" cy="280" r="4" fill="#5a9a3a"/>
            <circle cx="230" cy="273" r="6" fill="#3a7a1a"/>
            <circle cx="240" cy="268" r="4" fill="#4a8a2a"/>
            <circle cx="245" cy="276" r="3" fill="#5a9a3a"/>
          </g>
          <!-- Lichen on trunk -->
          <g opacity="0.2">
            <circle cx="175" cy="55" r="6" fill="#8a9a78"/>
            <circle cx="180" cy="52" r="3.5" fill="#9aaa88"/>
            <circle cx="225" cy="210" r="5" fill="#8a9a78"/>
            <circle cx="228" cy="207" r="3" fill="#9aaa88"/>
          </g>
        </svg>
      SVG
    },
    "wood_blewit" => {
      name: "Wood Blewit",
      name_ro: "Nicorete mov",
      latin: "Lepista nuda",
      description: "Ethereal violet-lilac caps rise from autumn leaf drifts in cool damp forests. One of the last mushrooms of the year, rewarding patient foragers who brave the first frosts.",
      description_ro: "Pălării violet-liliac eterice se ridică din mormane de frunze toamnale în păduri reci și umede. Una dintre ultimele ciuperci ale anului, răsplătind culegătorii răbdători care înfruntă primele înghețuri.",
      season_months: [8, 9, 10, 11, 12],
      temp_range: { ideal_min: 7, ideal_max: 15, abs_min: 4, abs_max: 18 },
      rain_range: { ideal_min: 8, ideal_max: 20, abs_min: 3, abs_max: 35 },
      delay_days: { ideal_min: 4, ideal_max: 10, abs_min: 2, abs_max: 21 },
      # Blewits respond to the cool-damp pattern of late autumn.
      # 5-day average captures the sustained cool+wet needed.
      temp_window: 5,
      # Leaf litter and humus-rich woodland or garden compost heaps.
      preferred_terrain: { ideal: ["deciduous", "mixed", "park"], partial: ["coniferous", "scrubland", "grassland", "orchard"], bad: ["farmland", "wetland", "water"] },
      tips: [
        "#{IconHelper.icon(:snowflake)} Cold triggers fruiting — scout after first frosts in late October",
        "#{IconHelper.icon(:fallen_leaf)} Dig in deep leaf litter and compost — colonies hide beneath the surface",
        "#{IconHelper.icon(:sparkle)} Violet stems are the key ID — true blewits have distinctly lilac stipes",
        "#{IconHelper.icon(:blossom)} Sweet fruity aroma when broken — scentless ones are likely imposters",
        "#{IconHelper.icon(:rain_heavy)} Hunt 4-10 days after autumn rains when temperatures drop below 12°C",
        "#{IconHelper.icon(:trail)} Garden compost heaps and leaf mulch piles are secret blewit spots",
        "#{IconHelper.icon(:hand_pick)} Later is better — blewits improve with frost, harvest into December"
      ],
      tips_ro: [
        "#{IconHelper.icon(:snowflake)} Frigul declanșează fructificarea — caută după primele înghețuri din octombrie",
        "#{IconHelper.icon(:fallen_leaf)} Caută în litiera adâncă de frunze și compost — coloniile se ascund sub suprafață",
        "#{IconHelper.icon(:sparkle)} Tulpinile violet sunt cheia identificării — vinețicile au picior distinctiv liliac",
        "#{IconHelper.icon(:blossom)} Aromă dulce-fructată când se rupe — cele fără miros sunt probabil impostoare",
        "#{IconHelper.icon(:rain_heavy)} Caută la 4-10 zile după ploile de toamnă când temperatura scade sub 12°C",
        "#{IconHelper.icon(:trail)} Grămezile de compost din grădini sunt locuri secrete pentru vinețici",
        "#{IconHelper.icon(:hand_pick)} Mai târziu e mai bine — vinețicile se îmbunătățesc cu îngheț, culege până în decembrie"
      ],
      color: "#9370DB",
      gradient_from: "#B08DD4",
      gradient_to: "#5B2C8E",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Clitocybe_Nuda,_AKA_Lepista_Nuda,_AKA_Wood_Blewit.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Lepista_nuda_LC0372.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Lepista_nuda,_Wood_Blewit,_UK.jpg?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="blewit-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#c0c8b0"/>
              <stop offset="50%" stop-color="#a0a888"/>
              <stop offset="100%" stop-color="#7a6a4a"/>
            </linearGradient>
            <linearGradient id="blewit-cap" x1="0.3" y1="0" x2="0.7" y2="1">
              <stop offset="0%" stop-color="#B08DD4"/>
              <stop offset="40%" stop-color="#9370DB"/>
              <stop offset="100%" stop-color="#6A3DA0"/>
            </linearGradient>
            <linearGradient id="blewit-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#B08DD4"/>
              <stop offset="30%" stop-color="#C8B0E8"/>
              <stop offset="70%" stop-color="#C0A8E0"/>
              <stop offset="100%" stop-color="#9A78C0"/>
            </linearGradient>
            <linearGradient id="blewit-gills" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#C8A8E8"/>
              <stop offset="100%" stop-color="#A080C8"/>
            </linearGradient>
            <filter id="blewit-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#blewit-bg)"/>
          <!-- Autumn forest floor -->
          <ellipse cx="200" cy="282" rx="220" ry="28" fill="#6b5a3a" opacity="0.25"/>
          <!-- Fallen leaves -->
          <g opacity="0.4">
            <ellipse cx="80" cy="270" rx="25" ry="6" fill="#b8862a" transform="rotate(-15 80 270)"/>
            <ellipse cx="130" cy="275" rx="20" ry="5" fill="#c49a30" transform="rotate(10 130 275)"/>
            <ellipse cx="280" cy="268" rx="28" ry="7" fill="#a07828" transform="rotate(20 280 268)"/>
            <ellipse cx="320" cy="274" rx="18" ry="5" fill="#b89030" transform="rotate(-8 320 274)"/>
            <ellipse cx="185" cy="278" rx="22" ry="5" fill="#c4a035" transform="rotate(5 185 278)"/>
            <ellipse cx="230" cy="276" rx="16" ry="4" fill="#a88828" transform="rotate(-12 230 276)"/>
          </g>
          <!-- Main blewit mushroom -->
          <g filter="url(#blewit-shadow)">
            <!-- Stem -->
            <path d="M188 275 Q184 258 183 235 Q183 215 186 200 Q188 194 193 190 L207 190 Q212 194 214 200 Q217 215 217 235 Q216 258 212 275 Z" fill="url(#blewit-stem)"/>
            <!-- Stem fibrous texture -->
            <g stroke="#9A70C0" stroke-width="0.5" fill="none" opacity="0.3">
              <path d="M192 270 Q191 250 192 220 Q192 205 193 195"/>
              <path d="M200 273 Q200 250 200 220 Q200 205 200 192"/>
              <path d="M208 270 Q209 250 208 220 Q208 205 207 195"/>
            </g>
            <!-- Gills -->
            <ellipse cx="200" cy="188" rx="60" ry="8" fill="url(#blewit-gills)"/>
            <g stroke="#9060B0" stroke-width="0.4" fill="none" opacity="0.3">
              <line x1="155" y1="188" x2="245" y2="188"/>
              <line x1="160" y1="186" x2="240" y2="186"/>
              <line x1="165" y1="190" x2="235" y2="190"/>
            </g>
            <!-- Cap — convex, smooth -->
            <path d="M135 184 Q140 150 160 130 Q180 115 200 112 Q220 115 240 130 Q260 150 265 184 Z" fill="url(#blewit-cap)"/>
            <!-- Cap highlight -->
            <path d="M160 130 Q180 118 200 116 Q210 116 220 120 Q200 115 185 125 Q170 138 162 155 Z" fill="#C8A8E8" opacity="0.3"/>
            <!-- Cap edge subtle ring -->
            <path d="M140 178 Q170 172 200 170 Q230 172 260 178" stroke="#7050A0" stroke-width="0.6" fill="none" opacity="0.3"/>
          </g>
          <!-- Small background blewit -->
          <g opacity="0.4" transform="translate(305, 230) scale(0.35)">
            <path d="M-10 60 Q-8 30 -5 15 L5 15 Q8 30 10 60 Z" fill="#B08DD4"/>
            <path d="M-30 12 Q-20 -10 0 -15 Q20 -10 30 12 Z" fill="#9370DB"/>
          </g>
          <!-- Grass tufts -->
          <path d="M100 278 Q102 266 98 258" stroke="#6b8a4a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M104 278 Q105 268 108 260" stroke="#7a9a5a" stroke-width="1" fill="none" opacity="0.3"/>
        </svg>
      SVG
    },
    "wood_ear" => {
      name: "Wood Ear",
      name_ro: "Buretele de soc",
      latin: "Auricularia auricula-judae",
      description: "Translucent ear-shaped jelly fungi cling to dead elder branches year-round, swelling after rain into dark rubbery lobes. A winter forager's treasure when nothing else fruits.",
      description_ro: "Ciuperci gelatinoase în formă de ureche se lipesc de ramurile moarte de soc tot anul, umflându-se după ploaie în lobi întunecați cauciucați. Comoara culegătorului de iarnă când nimic altceva nu fructifică.",
      season_months: [1, 2, 3, 4, 5, 9, 10, 11, 12],
      temp_range: { ideal_min: 10, ideal_max: 16, abs_min: 5, abs_max: 22 },
      rain_range: { ideal_min: 2, ideal_max: 10, abs_min: 1, abs_max: 20 },
      delay_days: { ideal_min: 1, ideal_max: 3, abs_min: 1, abs_max: 7 },
      # Jelly fungus on wood — responds very quickly to moisture.
      # 4-day temp window since it rehydrates fast after rain.
      temp_window: 4,
      # Grows on dead hardwood, especially elder. Needs forest with dead wood.
      preferred_terrain: { ideal: ["deciduous", "mixed"], partial: ["wetland", "park", "scrubland"], bad: ["coniferous", "grassland", "farmland", "orchard", "water"] },
      tips: [
        "#{IconHelper.icon(:log)} Elder trees are the #1 host — learn to recognize elder bark",
        "#{IconHelper.icon(:rain_heavy)} Best 1-3 days after rain when flesh is plump and hydrated",
        "#{IconHelper.icon(:snowflake)} Frost-proof — wood ears freeze and revive when thawed, forage all winter",
        "#{IconHelper.icon(:map_pin)} Mark elder trees with fruiting bodies — return monthly for repeat harvests",
        "#{IconHelper.icon(:hand_pick)} Pull gently from attachment point — entire ear detaches cleanly",
        "#{IconHelper.icon(:sun)} Dry and rehydrate — dried wood ears store for months and rehydrate perfectly",
        "#{IconHelper.icon(:fern)} Spring and autumn peaks — best tenderness April-May and September-November"
      ],
      tips_ro: [
        "#{IconHelper.icon(:log)} Socul este gazda #1 — învață să recunoști scoarța de soc",
        "#{IconHelper.icon(:rain_heavy)} Cel mai bine la 1-3 zile după ploaie când carnea este umflată și hidratată",
        "#{IconHelper.icon(:snowflake)} Rezistent la îngheț — urechile se înghață și revin la dezgheț, culege toată iarna",
        "#{IconHelper.icon(:map_pin)} Marchează copacii de soc — revino lunar pentru recolte repetate",
        "#{IconHelper.icon(:hand_pick)} Trage ușor din punctul de atașament — toată urechea se desprinde curat",
        "#{IconHelper.icon(:sun)} Usucă și rehidratează — urechile uscate se păstrează luni și se rehidratează perfect",
        "#{IconHelper.icon(:fern)} Vârfuri primăvara și toamna — cea mai bună frageditate aprilie-mai și septembrie-noiembrie"
      ],
      color: "#5C4033",
      gradient_from: "#8B7355",
      gradient_to: "#2C1810",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Auricularia_auricula-judae_a.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Auricularia_auricula-judae_64485.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Auricularia_auricula-judae,_Jelly_Ear_Fungus,_UK.jpg?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="we-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8a9878"/>
              <stop offset="35%" stop-color="#728868"/>
              <stop offset="70%" stop-color="#5a6850"/>
              <stop offset="100%" stop-color="#4a4a38"/>
            </linearGradient>
            <!-- Elder branch — pale grey-brown bark -->
            <linearGradient id="we-branch" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#9a9080"/>
              <stop offset="30%" stop-color="#7a7060"/>
              <stop offset="70%" stop-color="#6a6050"/>
              <stop offset="100%" stop-color="#5a5040"/>
            </linearGradient>
            <linearGradient id="we-branch-top" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#a8a090"/>
              <stop offset="100%" stop-color="#8a8070"/>
            </linearGradient>
            <!-- Ear inner surface — dark reddish-brown, smooth, concave -->
            <radialGradient id="we-ear-inner" cx="0.4" cy="0.35" r="0.65">
              <stop offset="0%" stop-color="#7a4a38"/>
              <stop offset="40%" stop-color="#5C3528"/>
              <stop offset="80%" stop-color="#3a2018"/>
              <stop offset="100%" stop-color="#2a1510"/>
            </radialGradient>
            <!-- Ear outer surface — velvety, lighter greyish-brown -->
            <radialGradient id="we-ear-outer" cx="0.5" cy="0.4" r="0.6">
              <stop offset="0%" stop-color="#8a7060"/>
              <stop offset="50%" stop-color="#6a5040"/>
              <stop offset="100%" stop-color="#4a3528"/>
            </radialGradient>
            <!-- Translucent wet jelly glow -->
            <radialGradient id="we-jelly" cx="0.4" cy="0.3" r="0.5">
              <stop offset="0%" stop-color="#b08868" stop-opacity="0.3"/>
              <stop offset="100%" stop-color="#6a4030" stop-opacity="0"/>
            </radialGradient>
            <!-- Wet gloss highlight -->
            <radialGradient id="we-gloss" cx="0.3" cy="0.25" r="0.4">
              <stop offset="0%" stop-color="#fff" stop-opacity="0.15"/>
              <stop offset="100%" stop-color="#fff" stop-opacity="0"/>
            </radialGradient>
            <radialGradient id="we-dapple" cx="0.5" cy="0.5" r="0.5">
              <stop offset="0%" stop-color="#b8c8a0" stop-opacity="0.15"/>
              <stop offset="100%" stop-color="#b8c8a0" stop-opacity="0"/>
            </radialGradient>
            <filter id="we-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.18"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#we-bg)"/>
          <!-- Dappled forest light -->
          <ellipse cx="80" cy="50" rx="50" ry="35" fill="url(#we-dapple)"/>
          <ellipse cx="320" cy="40" rx="45" ry="30" fill="url(#we-dapple)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="286" rx="230" ry="28" fill="#4a4030" opacity="0.25"/>
          <!-- ===== ELDER BRANCH — diagonal, thick, with character ===== -->
          <!-- Branch shadow on ground -->
          <ellipse cx="200" cy="282" rx="140" ry="6" fill="#3a3020" opacity="0.1"/>
          <!-- Main branch body -->
          <path d="M55 210 Q120 188 200 160 Q280 132 370 100" stroke="url(#we-branch)" stroke-width="32" fill="none" stroke-linecap="round"/>
          <!-- Branch top highlight (round surface feel) -->
          <path d="M60 206 Q125 184 205 156 Q280 128 365 96" stroke="url(#we-branch-top)" stroke-width="18" fill="none" stroke-linecap="round" opacity="0.5"/>
          <!-- Elder bark texture — pale with distinctive lenticels (raised dots) -->
          <g opacity="0.2">
            <!-- Longitudinal bark cracks -->
            <path d="M80 208 Q110 198 145 188 Q175 178 205 168" stroke="#5a4a38" stroke-width="0.7" fill="none"/>
            <path d="M85 215 Q115 205 150 195 Q180 185 210 175" stroke="#5a4a38" stroke-width="0.5" fill="none"/>
            <path d="M195 165 Q230 154 265 142 Q300 130 335 118" stroke="#5a4a38" stroke-width="0.6" fill="none"/>
            <path d="M200 172 Q235 160 270 148 Q305 136 340 124" stroke="#5a4a38" stroke-width="0.4" fill="none"/>
          </g>
          <!-- Elder lenticels (small raised bumps on bark) -->
          <g fill="#8a8070" opacity="0.25">
            <ellipse cx="100" cy="202" rx="2" ry="1"/>
            <ellipse cx="130" cy="193" rx="1.5" ry="0.8"/>
            <ellipse cx="165" cy="182" rx="2" ry="1"/>
            <ellipse cx="220" cy="160" rx="1.5" ry="0.8"/>
            <ellipse cx="260" cy="146" rx="2" ry="1"/>
            <ellipse cx="295" cy="133" rx="1.5" ry="0.8"/>
            <ellipse cx="330" cy="120" rx="1.8" ry="0.9"/>
          </g>
          <!-- Small side twig (broken off) -->
          <path d="M290 130 Q295 122 300 115" stroke="#6a6050" stroke-width="5" fill="none" stroke-linecap="round"/>
          <ellipse cx="300" cy="115" rx="3" ry="3" fill="#5a5040"/>
          <!-- ===== WOOD EAR FUNGI — realistic ear/cup shapes ===== -->
          <g filter="url(#we-shadow)">
            <!-- === EAR 1 (large, hero, hanging down-left from branch) === -->
            <!-- Outer velvety surface visible on the back curl -->
            <path d="M148 178 Q135 174 128 182 Q122 192 125 205 Q128 215 135 220" fill="url(#we-ear-outer)"/>
            <!-- Main ear cup — concave inner surface facing viewer -->
            <path d="M148 178 Q138 185 132 198 Q128 212 135 226
                     Q142 238 158 240 Q172 238 182 228
                     Q190 216 188 200 Q185 186 178 178
                     Q168 170 148 178 Z" fill="url(#we-ear-inner)"/>
            <!-- Concentric folds/wrinkles on inner surface (key realistic detail) -->
            <g stroke="#4a2818" fill="none" opacity="0.3">
              <path d="M148 185 Q140 192 138 205 Q137 215 142 225 Q148 232 158 234" stroke-width="0.7"/>
              <path d="M152 190 Q145 196 143 206 Q142 215 146 222 Q150 228 158 230" stroke-width="0.6"/>
              <path d="M156 195 Q150 200 148 208 Q148 216 150 220 Q154 225 160 226" stroke-width="0.5"/>
              <path d="M160 198 Q156 203 155 210 Q155 216 157 219" stroke-width="0.4"/>
            </g>
            <!-- Veins radiating from attachment point -->
            <g stroke="#5a3020" fill="none" opacity="0.2">
              <path d="M168 178 Q155 195 145 218" stroke-width="0.6"/>
              <path d="M170 180 Q162 200 158 225" stroke-width="0.5"/>
              <path d="M172 182 Q170 205 172 230" stroke-width="0.5"/>
              <path d="M175 180 Q178 202 180 222" stroke-width="0.4"/>
            </g>
            <!-- Wet translucent jelly glow -->
            <path d="M148 185 Q142 195 140 210 Q140 222 148 232 Q155 225 152 210 Q150 195 148 185 Z" fill="url(#we-jelly)"/>
            <!-- Glossy wet highlight -->
            <ellipse cx="150" cy="200" rx="10" ry="14" fill="url(#we-gloss)"/>
            <!-- Rim highlight (thin wavy edge catches light) -->
            <path d="M135 226 Q142 238 158 240 Q172 238 182 228" stroke="#9a7860" stroke-width="0.6" fill="none" opacity="0.3"/>

            <!-- === EAR 2 (medium, right-center, more upright cup) === -->
            <path d="M232 142 Q222 138 216 144 Q212 152 214 164" fill="url(#we-ear-outer)"/>
            <path d="M232 142 Q224 148 220 160
                     Q218 174 224 185 Q230 194 244 196
                     Q256 194 264 184 Q270 172 268 158
                     Q264 146 256 140 Q246 136 232 142 Z" fill="url(#we-ear-inner)"/>
            <!-- Inner wrinkles -->
            <g stroke="#4a2818" fill="none" opacity="0.28">
              <path d="M234 150 Q227 158 225 168 Q224 178 228 186 Q233 192 242 194" stroke-width="0.6"/>
              <path d="M238 155 Q232 162 230 170 Q230 178 233 184 Q236 188 242 190" stroke-width="0.5"/>
              <path d="M242 158 Q238 164 236 172 Q236 178 238 182" stroke-width="0.4"/>
            </g>
            <!-- Veins from attachment -->
            <g stroke="#5a3020" fill="none" opacity="0.18">
              <path d="M248 142 Q238 158 230 180" stroke-width="0.5"/>
              <path d="M250 144 Q245 165 244 188" stroke-width="0.4"/>
              <path d="M252 146 Q254 168 258 186" stroke-width="0.4"/>
            </g>
            <ellipse cx="236" cy="165" rx="8" ry="11" fill="url(#we-gloss)"/>
            <path d="M224 185 Q230 194 244 196 Q256 194 264 184" stroke="#9a7860" stroke-width="0.5" fill="none" opacity="0.25"/>

            <!-- === EAR 3 (small, upper right, younger specimen) === -->
            <path d="M305 114 Q298 110 293 114 Q290 120 292 130" fill="url(#we-ear-outer)" opacity="0.8"/>
            <path d="M305 114 Q298 118 295 128
                     Q294 138 298 146 Q304 152 314 152
                     Q322 150 326 142 Q328 132 324 122
                     Q320 114 312 112 Q308 112 305 114 Z" fill="url(#we-ear-inner)"/>
            <!-- Inner wrinkles -->
            <g stroke="#4a2818" fill="none" opacity="0.25">
              <path d="M306 120 Q300 126 298 134 Q298 142 302 148" stroke-width="0.5"/>
              <path d="M309 124 Q304 130 303 136 Q303 142 306 146" stroke-width="0.4"/>
            </g>
            <ellipse cx="304" cy="132" rx="5" ry="7" fill="url(#we-gloss)"/>

            <!-- === EAR 4 (tiny baby, between ear 1 and 2, just emerging) === -->
            <path d="M195 170 Q190 168 188 172 Q186 178 188 186
                     Q190 192 196 194 Q202 192 206 186
                     Q208 178 205 172 Q202 168 195 170 Z" fill="url(#we-ear-inner)" opacity="0.7"/>
            <path d="M196 174 Q192 178 191 184 Q192 189 195 192" stroke="#4a2818" stroke-width="0.4" fill="none" opacity="0.2"/>

            <!-- === EAR 5 (tiny, far left on branch, partially behind) === -->
            <path d="M100 204 Q95 202 92 206 Q90 212 92 220
                     Q94 226 100 228 Q106 226 110 220
                     Q112 212 109 206 Q106 202 100 204 Z" fill="url(#we-ear-inner)" opacity="0.6"/>
            <path d="M101 208 Q96 212 95 218 Q96 224 99 226" stroke="#4a2818" stroke-width="0.35" fill="none" opacity="0.2"/>
          </g>
          <!-- Lichen spots on branch (greenish-grey circles) -->
          <g opacity="0.3">
            <circle cx="115" cy="198" r="5" fill="#8a9a78"/>
            <circle cx="118" cy="195" r="3" fill="#9aaa88" opacity="0.6"/>
            <circle cx="340" cy="110" r="4" fill="#8a9a78"/>
            <circle cx="343" cy="107" r="2.5" fill="#9aaa88" opacity="0.5"/>
          </g>
          <!-- Green moss on branch -->
          <g opacity="0.4">
            <circle cx="78" cy="210" r="4" fill="#4a8a2a"/>
            <circle cx="84" cy="207" r="3" fill="#5a9a3a"/>
            <circle cx="355" cy="100" r="3.5" fill="#4a8a2a"/>
            <circle cx="360" cy="97" r="2.5" fill="#5a9a3a"/>
          </g>
        </svg>
      SVG
    },
    "field_mushroom" => {
      name: "Field Mushroom",
      name_ro: "Champignon sălbatic",
      latin: "Agaricus campestris",
      description: "Cream-white caps with pink-then-chocolate gills dot morning meadows after summer rainstorms. The wild ancestor of the cultivated button mushroom, richer in earthy woodland fragrance.",
      description_ro: "Pălării alb-crem cu lamele roz apoi ciocolatii punctează pajiștile dimineții după furtunile de vară. Strămoșul sălbatic al ciupercii de cultură, mai bogat în aromă pământoasă.",
      season_months: [6, 7, 8, 9, 10, 11],
      temp_range: { ideal_min: 13, ideal_max: 20, abs_min: 8, abs_max: 28 },
      rain_range: { ideal_min: 10, ideal_max: 25, abs_min: 5, abs_max: 40 },
      delay_days: { ideal_min: 2, ideal_max: 5, abs_min: 1, abs_max: 10 },
      # Grassland species, responds to warm rain on soil.
      # 5-day window captures the rain+warmth combination that triggers flushes.
      temp_window: 5,
      # Classic meadow mushroom — needs open grassland, not forest.
      preferred_terrain: { ideal: ["grassland", "farmland", "park"], partial: ["orchard", "scrubland"], bad: ["deciduous", "coniferous", "mixed", "wetland", "water"] },
      tips: [
        "#{IconHelper.icon(:clearing)} Open meadows and maintained pastures only — avoid woodland",
        "#{IconHelper.icon(:storm)} Hunt 2-5 days after warm rain over 15mm — triggers synchronized flushes",
        "#{IconHelper.icon(:sunrise)} Morning ritual — forage before 9 AM when dew keeps flesh firm",
        "#{IconHelper.icon(:sparkle)} Pink gill check — young ones have pink gills, older turn chocolate brown",
        "#{IconHelper.icon(:hand_pick)} Press the cap gently — intact veil underneath means prime condition",
        "#{IconHelper.icon(:amanita)} Careful: never confuse with yellow-staining Agaricus xanthodermus",
        "#{IconHelper.icon(:sun)} August-October peak in Romania as summer heat gives way to cool damp weather"
      ],
      tips_ro: [
        "#{IconHelper.icon(:clearing)} Doar pajiști deschise și pășuni întreținute — evită pădurile",
        "#{IconHelper.icon(:storm)} Caută la 2-5 zile după ploaie caldă peste 15mm — declanșează apariția sincronizată",
        "#{IconHelper.icon(:sunrise)} Ritual matinal — culege înainte de ora 9 când roua păstrează carnea fermă",
        "#{IconHelper.icon(:sparkle)} Verifică lamelele roz — cele tinere au lamele roz, cele vechi devin ciocolatii",
        "#{IconHelper.icon(:hand_pick)} Apasă ușor pe pălărie — vălul intact dedesubt înseamnă stare perfectă",
        "#{IconHelper.icon(:amanita)} Atenție: nu confunda cu Agaricus xanthodermus care se îngălbenește la tăiere",
        "#{IconHelper.icon(:sun)} Vârf august-octombrie în România când căldura verii cedează vremii reci și umede"
      ],
      color: "#F5DEB3",
      gradient_from: "#FFFAF0",
      gradient_to: "#C4A872",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Agaricus_campestris_051011A.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Agaricus_campestris_garden_050830B.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Field_mushrooms_(Agaricus_Campestris)_-_geograph.org.uk_-_604856.jpg?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="fm-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#b8d4e8"/>
              <stop offset="40%" stop-color="#90c890"/>
              <stop offset="100%" stop-color="#6a9a50"/>
            </linearGradient>
            <radialGradient id="fm-cap" cx="0.45" cy="0.3" r="0.6">
              <stop offset="0%" stop-color="#FFFFF0"/>
              <stop offset="60%" stop-color="#F5E8D0"/>
              <stop offset="100%" stop-color="#E0CCA8"/>
            </radialGradient>
            <linearGradient id="fm-stem" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#E8DCC8"/>
              <stop offset="30%" stop-color="#F8F0E4"/>
              <stop offset="70%" stop-color="#F5ECD8"/>
              <stop offset="100%" stop-color="#E0D0B8"/>
            </linearGradient>
            <linearGradient id="fm-gills" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#E8A0B0"/>
              <stop offset="100%" stop-color="#C87888"/>
            </linearGradient>
            <filter id="fm-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#fm-bg)"/>
          <!-- Grass meadow ground -->
          <ellipse cx="200" cy="278" rx="240" ry="30" fill="#5a8a38" opacity="0.3"/>
          <!-- Grass blades -->
          <g stroke="#4a7a2a" fill="none" opacity="0.4">
            <path d="M60 275 Q62 260 58 248" stroke-width="1.5"/>
            <path d="M65 275 Q67 262 70 250" stroke-width="1.2"/>
            <path d="M120 278 Q118 265 122 254" stroke-width="1.3"/>
            <path d="M125 278 Q127 266 124 256" stroke-width="1.1"/>
            <path d="M270 276 Q268 264 272 254" stroke-width="1.4"/>
            <path d="M275 276 Q277 265 274 256" stroke-width="1.1"/>
            <path d="M335 274 Q333 262 337 252" stroke-width="1.3"/>
            <path d="M340 275 Q342 264 339 255" stroke-width="1.1"/>
          </g>
          <!-- Main field mushroom -->
          <g filter="url(#fm-shadow)">
            <!-- Stem -->
            <path d="M186 274 Q182 258 182 238 Q182 220 185 208 Q187 202 192 198 L208 198 Q213 202 215 208 Q218 220 218 238 Q218 258 214 274 Z" fill="url(#fm-stem)"/>
            <!-- Ring/annulus on stem -->
            <ellipse cx="200" cy="218" rx="15" ry="3" fill="#F0E4D0" stroke="#D8C8A8" stroke-width="0.5"/>
            <!-- Gills (pink) -->
            <ellipse cx="200" cy="196" rx="70" ry="8" fill="url(#fm-gills)"/>
            <g stroke="#B06878" stroke-width="0.4" fill="none" opacity="0.3">
              <line x1="145" y1="196" x2="255" y2="196"/>
              <line x1="150" y1="194" x2="250" y2="194"/>
              <line x1="148" y1="198" x2="252" y2="198"/>
            </g>
            <!-- Cap — broad dome, white/cream -->
            <path d="M125 192 Q128 160 150 140 Q175 122 200 118 Q225 122 250 140 Q272 160 275 192 Z" fill="url(#fm-cap)"/>
            <!-- Cap smooth sheen -->
            <path d="M155 138 Q175 125 200 122 Q215 123 228 128 Q210 122 190 130 Q168 142 158 160 Z" fill="#FFFFFF" opacity="0.2"/>
            <!-- Cap edge shadow -->
            <path d="M255 145 Q268 158 273 180 Q274 188 275 192" stroke="#C8B898" stroke-width="0.8" fill="none" opacity="0.3"/>
          </g>
          <!-- Small background mushrooms -->
          <g opacity="0.35">
            <g transform="translate(90, 245) scale(0.3)">
              <path d="M-8 50 Q-6 25 -4 10 L4 10 Q6 25 8 50 Z" fill="#F0E4D0"/>
              <path d="M-25 8 Q-15 -12 0 -16 Q15 -12 25 8 Z" fill="#F5E8D0"/>
            </g>
            <g transform="translate(310, 240) scale(0.25)">
              <path d="M-8 50 Q-6 25 -4 10 L4 10 Q6 25 8 50 Z" fill="#F0E4D0"/>
              <path d="M-25 8 Q-15 -12 0 -16 Q15 -12 25 8 Z" fill="#F5E8D0"/>
            </g>
          </g>
        </svg>
      SVG
    },
    "black_trumpet" => {
      name: "Black Trumpet",
      name_ro: "Trâmbița piticului",
      latin: "Craterellus cornucopioides",
      description: "Dark funnel-shaped phantoms emerge from mossy beech and oak leaf litter in cool autumns. Prized by chefs for their subtle truffle-like depth and delicate, smoky aroma.",
      description_ro: "Fantome întunecate în formă de pâlnie apar din litiera de frunze cu mușchi de fag și stejar în toamnele reci. Apreciate de bucătari pentru profunzimea subtilă de trufe și aroma delicată, afumată.",
      season_months: [7, 8, 9, 10, 11],
      temp_range: { ideal_min: 13, ideal_max: 18, abs_min: 8, abs_max: 21 },
      rain_range: { ideal_min: 12, ideal_max: 30, abs_min: 10, abs_max: 50 },
      delay_days: { ideal_min: 5, ideal_max: 12, abs_min: 3, abs_max: 21 },
      # Slow to fruit — needs sustained cool moisture.
      # 5-day window captures the prolonged damp needed.
      temp_window: 5,
      # Deep forest species, beech and oak litter.
      preferred_terrain: { ideal: ["deciduous", "mixed"], partial: ["coniferous", "scrubland"], bad: ["grassland", "farmland", "wetland", "park", "orchard", "water"] },
      tips: [
        "#{IconHelper.icon(:moss)} Follow moss patches in beech and oak groves — black trumpets hide in damp leaf litter",
        "#{IconHelper.icon(:rain_heavy)} Need sustained rain — hunt 5-12 days after 15mm+ rainfall for best results",
        "#{IconHelper.icon(:fallen_leaf)} Scrape gently through leaves — they hide under 5cm of leaf cover",
        "#{IconHelper.icon(:hand_pick)} Completely hollow inside — break one to confirm, solid cores are a different species",
        "#{IconHelper.icon(:sparkle)} Dried trumpets smell intensely fruity and aromatic — scentless ones are fakes",
        "#{IconHelper.icon(:umbrella)} Handle gently in baskets with paper — thin walls shatter in plastic bags",
        "#{IconHelper.icon(:map_pin)} September-October peak — plan foraging when cool rain and 13-18°C temps align"
      ],
      tips_ro: [
        "#{IconHelper.icon(:moss)} Urmărește petele de mușchi în păduri de fag și stejar — trompetele se ascund în litieră umedă",
        "#{IconHelper.icon(:rain_heavy)} Necesită ploaie susținută — caută la 5-12 zile după 15mm+ pentru cele mai bune rezultate",
        "#{IconHelper.icon(:fallen_leaf)} Curăță ușor prin frunze — se ascund sub 5cm de acoperire de frunze",
        "#{IconHelper.icon(:hand_pick)} Complet gol pe interior — rupe una pentru a confirma, nucleele solide sunt altă specie",
        "#{IconHelper.icon(:sparkle)} Trompetele uscate au miros intens fructat și aromatic — cele fără miros sunt false",
        "#{IconHelper.icon(:umbrella)} Manipulează ușor în coșuri cu hârtie — pereții subțiri se sfărâmă în pungi de plastic",
        "#{IconHelper.icon(:map_pin)} Vârf septembrie-octombrie — planifică când ploaia rece și temperaturile de 13-18°C se aliniază"
      ],
      color: "#2C2C2C",
      gradient_from: "#4A4A4A",
      gradient_to: "#0A0A0A",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Craterellus_cornucopioides_a1.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Craterellus_cornucopioides_Eestis.JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/0_Craterellus_cornucopioides_-_Trompette_de_la_mort_(2).JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="bt-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#7a8a68"/>
              <stop offset="40%" stop-color="#6a7a58"/>
              <stop offset="70%" stop-color="#5a6848"/>
              <stop offset="100%" stop-color="#4a4030"/>
            </linearGradient>
            <linearGradient id="bt-body" x1="0.3" y1="1" x2="0.7" y2="0">
              <stop offset="0%" stop-color="#1a1a1a"/>
              <stop offset="40%" stop-color="#2c2c2c"/>
              <stop offset="100%" stop-color="#484848"/>
            </linearGradient>
            <linearGradient id="bt-inner" x1="0" y1="1" x2="0" y2="0">
              <stop offset="0%" stop-color="#0a0a0a"/>
              <stop offset="100%" stop-color="#282828"/>
            </linearGradient>
            <radialGradient id="bt-shine" cx="0.35" cy="0.3" r="0.5">
              <stop offset="0%" stop-color="#606060" stop-opacity="0.3"/>
              <stop offset="100%" stop-color="#2c2c2c" stop-opacity="0"/>
            </radialGradient>
            <filter id="bt-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#bt-bg)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="282" rx="220" ry="28" fill="#4a4028" opacity="0.25"/>
          <ellipse cx="200" cy="278" rx="200" ry="18" fill="#5a5030" opacity="0.2"/>
          <!-- Moss carpet -->
          <g opacity="0.38">
            <circle cx="65" cy="273" r="9" fill="#3a7a1a"/>
            <circle cx="78" cy="270" r="6" fill="#4a8a2a"/>
            <circle cx="58" cy="276" r="5" fill="#2a6a10"/>
            <circle cx="90" cy="271" r="4" fill="#4a8a2a"/>
            <circle cx="330" cy="271" r="8" fill="#3a7a1a"/>
            <circle cx="342" cy="268" r="6" fill="#4a8a2a"/>
            <circle cx="322" cy="274" r="5" fill="#2a6a10"/>
            <circle cx="352" cy="272" r="4" fill="#4a8a2a"/>
            <circle cx="150" cy="276" r="5" fill="#3a7a1a"/>
            <circle cx="245" cy="275" r="6" fill="#3a7a1a"/>
            <circle cx="255" cy="273" r="4" fill="#4a8a2a"/>
          </g>
          <!-- Fallen beech leaves -->
          <path d="M100 270 Q112 262 120 268 Q114 256 104 258 Q96 262 100 270 Z" fill="#7a6828" opacity="0.35"/>
          <line x1="100" y1="270" x2="115" y2="260" stroke="#6a5820" stroke-width="0.5" opacity="0.3"/>
          <path d="M290 268 Q300 260 310 266 Q304 256 296 258 Q288 262 290 268 Z" fill="#6a5820" opacity="0.3"/>
          <!-- Small twigs -->
          <line x1="170" y1="278" x2="195" y2="274" stroke="#5a5030" stroke-width="1" opacity="0.25"/>
          <line x1="210" y1="277" x2="235" y2="273" stroke="#5a5030" stroke-width="0.8" opacity="0.2"/>
          <!-- Main black trumpet with shadow (chanterelle-style funnel) -->
          <g filter="url(#bt-shadow)">
            <!-- Stem - tapers from narrow base to wide funnel -->
            <path d="M192 278 Q188 262 186 245 Q184 228 183 215 Q182 202 184 192 L216 192 Q218 202 217 215 Q216 228 214 245 Q212 262 208 278 Z" fill="url(#bt-body)"/>
            <!-- Stem texture (vertical ridges like chanterelle) -->
            <path d="M194 275 Q193 258 192 238 Q192 218 193 198" stroke="#3a3a3a" stroke-width="0.6" fill="none" opacity="0.35"/>
            <path d="M200 278 Q200 255 200 235 Q200 215 200 195" stroke="#3a3a3a" stroke-width="0.5" fill="none" opacity="0.3"/>
            <path d="M206 275 Q207 258 208 238 Q208 218 207 198" stroke="#3a3a3a" stroke-width="0.6" fill="none" opacity="0.35"/>
            <!-- Left stem shadow -->
            <path d="M192 278 Q188 262 186 245 Q184 228 183 215 Q182 202 184 192 L190 192 Q188 205 188 218 Q188 235 190 252 Q191 265 194 278 Z" fill="#0a0a0a" opacity="0.2"/>
            <!-- Funnel/trumpet cap — organic wavy edges (like chanterelle shape) -->
            <path d="M184 192 Q178 178 168 162 Q158 148 142 132 Q134 124 124 118
                     L128 112 Q140 118 150 128 Q162 140 172 156
                     Q180 145 190 136 Q198 128 200 124
                     Q202 128 210 136 Q220 145 228 156
                     Q238 140 250 128 Q260 118 272 112
                     L276 118 Q266 124 258 132 Q242 148 232 162 Q222 178 216 192 Z"
                  fill="url(#bt-body)"/>
            <!-- Cap highlight (left side light) -->
            <path d="M184 192 Q178 178 168 162 Q158 148 142 132 Q134 124 124 118
                     L128 112 Q140 118 150 128 Q160 140 168 152 Q172 148 176 155 Q180 145 188 136 Q196 128 200 124
                     Q198 130 192 140 Q186 152 182 168 Q180 178 184 192 Z"
                  fill="url(#bt-shine)"/>
            <!-- False gill ridges running down from cap edge (like chanterelle but dark) -->
            <g stroke="#444" fill="none" opacity="0.4">
              <!-- Left side ridges -->
              <path d="M186 192 Q180 175 170 158 Q162 145 150 132" stroke-width="0.9"/>
              <path d="M188 192 Q184 178 176 164 Q170 152 160 140" stroke-width="0.8"/>
              <path d="M190 192 Q188 180 183 168 Q178 156 170 146" stroke-width="0.7"/>
              <path d="M193 192 Q192 180 189 170 Q186 160 180 150" stroke-width="0.7"/>
              <path d="M196 192 Q196 178 194 168 Q192 158 188 148" stroke-width="0.6"/>
              <!-- Right side ridges -->
              <path d="M214 192 Q220 175 230 158 Q238 145 250 132" stroke-width="0.9"/>
              <path d="M212 192 Q216 178 224 164 Q230 152 240 140" stroke-width="0.8"/>
              <path d="M210 192 Q212 180 217 168 Q222 156 230 146" stroke-width="0.7"/>
              <path d="M207 192 Q208 180 211 170 Q214 160 220 150" stroke-width="0.7"/>
              <path d="M204 192 Q204 178 206 168 Q208 158 212 148" stroke-width="0.6"/>
              <!-- Ridge forks -->
              <path d="M170 158 Q166 152 158 144" stroke-width="0.5"/>
              <path d="M176 164 Q174 160 168 154" stroke-width="0.5"/>
              <path d="M230 158 Q234 152 242 144" stroke-width="0.5"/>
              <path d="M224 164 Q226 160 232 154" stroke-width="0.5"/>
            </g>
            <!-- Wavy cap edge detail -->
            <path d="M124 118 Q128 114 128 112" stroke="#383838" stroke-width="1" fill="none" opacity="0.3"/>
            <path d="M276 118 Q274 114 272 112" stroke="#383838" stroke-width="1" fill="none" opacity="0.3"/>
            <!-- Cap outer edge shadow (right side) -->
            <path d="M228 156 Q238 140 250 128 Q260 118 272 112
                     L276 118 Q266 124 258 132 Q246 144 236 158 Q226 172 220 186 Z"
                  fill="#000" opacity="0.15"/>
          </g>
          <!-- Grass tufts -->
          <path d="M135 276 Q137 264 133 254" stroke="#3a7a1a" stroke-width="1.4" fill="none" opacity="0.4"/>
          <path d="M139 277 Q140 266 143 256" stroke="#4a8a2a" stroke-width="1.1" fill="none" opacity="0.35"/>
          <path d="M260 275 Q258 264 262 255" stroke="#3a7a1a" stroke-width="1.3" fill="none" opacity="0.35"/>
          <path d="M264 276 Q266 265 263 256" stroke="#4a8a2a" stroke-width="1" fill="none" opacity="0.3"/>
          <!-- Fern frond -->
          <g opacity="0.25" transform="translate(310, 248) scale(0.6)">
            <path d="M0 40 Q10 30 20 20 Q30 10 40 0" stroke="#3a7a1a" stroke-width="1.5" fill="none"/>
            <path d="M8 34 Q4 28 0 30" stroke="#3a7a1a" stroke-width="0.8" fill="none"/>
            <path d="M14 28 Q10 22 6 24" stroke="#3a7a1a" stroke-width="0.8" fill="none"/>
            <path d="M20 22 Q16 16 12 18" stroke="#3a7a1a" stroke-width="0.8" fill="none"/>
            <path d="M16 30 Q20 24 24 28" stroke="#3a7a1a" stroke-width="0.8" fill="none"/>
            <path d="M22 24 Q26 18 30 22" stroke="#3a7a1a" stroke-width="0.8" fill="none"/>
            <path d="M28 18 Q32 12 36 16" stroke="#3a7a1a" stroke-width="0.8" fill="none"/>
          </g>
        </svg>
      SVG
    },
    "amethyst_deceiver" => {
      name: "Amethyst Deceiver",
      name_ro: "Amăgitoare de ametist",
      latin: "Laccaria amethystina",
      description: "Diminutive vivid purple caps carpet damp oak and beech litter in cool autumns. Easily overlooked, but keen-eyed foragers find them in prolific fairy rings and dense clusters.",
      description_ro: "Pălării micuțe de un violet intens acoperă litiera umedă de stejar și fag în toamnele reci. Ușor de trecut cu vederea, dar culegătorii atenți le găsesc în cercuri de zâne și grupuri dense.",
      season_months: [8, 9, 10, 11],
      temp_range: { ideal_min: 11, ideal_max: 17, abs_min: 6, abs_max: 20 },
      rain_range: { ideal_min: 10, ideal_max: 25, abs_min: 5, abs_max: 40 },
      delay_days: { ideal_min: 4, ideal_max: 10, abs_min: 2, abs_max: 18 },
      # Mycorrhizal with oaks and beeches — responds to soil moisture.
      # 4-day temp window as small fruiting bodies appear quickly.
      temp_window: 4,
      # Deciduous woodland, especially oak and beech with rich humus.
      preferred_terrain: { ideal: ["deciduous", "mixed"], partial: ["coniferous", "park", "scrubland"], bad: ["grassland", "farmland", "orchard", "wetland", "water"] },
      tips: [
        "#{IconHelper.icon(:sparkle)} Spot one, find hundreds — they fruit in dense fairy rings and clusters",
        "#{IconHelper.icon(:tree_deciduous)} Oak, beech, and birch woods with acidic humus-rich soil",
        "#{IconHelper.icon(:hand_pick)} Harvest caps 1-3cm diameter — smaller specimens are sweeter and more tender",
        "#{IconHelper.icon(:rain_heavy)} Peak after weeks of steady September-October rainfall with cool nights",
        "#{IconHelper.icon(:moss)} Look where moss meets leaf litter — the damp transition zone is prime",
        "#{IconHelper.icon(:blossom)} Vivid purple colour is unique — fading to brownish signals drying out",
        "#{IconHelper.icon(:map_pin)} Hunt 4-10 days after significant rain when soil moisture stabilizes"
      ],
      tips_ro: [
        "#{IconHelper.icon(:sparkle)} Găsești una, găsești sute — fructifică în cercuri de zâne și grupuri dense",
        "#{IconHelper.icon(:tree_deciduous)} Păduri de stejar, fag și mesteacăn cu sol acid bogat în humus",
        "#{IconHelper.icon(:hand_pick)} Recoltează pălării de 1-3cm diametru — specimenele mici sunt mai dulci și fragede",
        "#{IconHelper.icon(:rain_heavy)} Vârf după săptămâni de ploaie constantă septembrie-octombrie cu nopți reci",
        "#{IconHelper.icon(:moss)} Caută unde mușchiul întâlnește litiera de frunze — zona umedă de tranziție este ideală",
        "#{IconHelper.icon(:blossom)} Culoarea violet intens este unică — decolorarea la maro semnalează uscarea",
        "#{IconHelper.icon(:map_pin)} Caută la 4-10 zile după ploaie semnificativă când umiditatea solului se stabilizează"
      ],
      color: "#9932CC",
      gradient_from: "#C77CEB",
      gradient_to: "#5B1B8E",
      photos: [
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Amethyst_Deceiver_-_Laccaria_amethystea_-_Violetter_Lacktrichterling_-_Laccaria_amethystina_-_01.jpg?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Laccaria_amethystina_G4_(1).JPG?width=400" },
        { url: "https://commons.wikimedia.org/wiki/Special:FilePath/Laccaria_amethystina.JPG?width=400" },
      ],
      svg: <<~SVG
        <svg viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="ad-bg" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8a9a70"/>
              <stop offset="40%" stop-color="#728860"/>
              <stop offset="70%" stop-color="#5a6848"/>
              <stop offset="100%" stop-color="#4a4030"/>
            </linearGradient>
            <linearGradient id="ad-cap1" x1="0.2" y1="0" x2="0.8" y2="1">
              <stop offset="0%" stop-color="#D8A0F8"/>
              <stop offset="25%" stop-color="#C77CEB"/>
              <stop offset="55%" stop-color="#9932CC"/>
              <stop offset="100%" stop-color="#6A1B8E"/>
            </linearGradient>
            <linearGradient id="ad-cap2" x1="0.3" y1="0" x2="0.6" y2="1">
              <stop offset="0%" stop-color="#D090F0"/>
              <stop offset="40%" stop-color="#B060D8"/>
              <stop offset="100%" stop-color="#7A28A8"/>
            </linearGradient>
            <linearGradient id="ad-stem1" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#A868C8"/>
              <stop offset="25%" stop-color="#C890E8"/>
              <stop offset="50%" stop-color="#D8A8F0"/>
              <stop offset="75%" stop-color="#C088E0"/>
              <stop offset="100%" stop-color="#9A60B8"/>
            </linearGradient>
            <linearGradient id="ad-stem2" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stop-color="#B878D0"/>
              <stop offset="50%" stop-color="#D09CE8"/>
              <stop offset="100%" stop-color="#A870C0"/>
            </linearGradient>
            <linearGradient id="ad-gills" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#C890E8"/>
              <stop offset="100%" stop-color="#9050B0"/>
            </linearGradient>
            <radialGradient id="ad-cap-shine" cx="0.35" cy="0.3" r="0.5">
              <stop offset="0%" stop-color="#E8C0FF" stop-opacity="0.5"/>
              <stop offset="100%" stop-color="#9932CC" stop-opacity="0"/>
            </radialGradient>
            <radialGradient id="ad-dapple" cx="0.5" cy="0.5" r="0.5">
              <stop offset="0%" stop-color="#c8d8a0" stop-opacity="0.15"/>
              <stop offset="100%" stop-color="#c8d8a0" stop-opacity="0"/>
            </radialGradient>
            <filter id="ad-shadow" x="-20%" y="-10%" width="140%" height="130%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
              <feOffset dx="3" dy="5"/>
              <feComponentTransfer><feFuncA type="linear" slope="0.15"/></feComponentTransfer>
              <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>
          <rect width="400" height="300" fill="url(#ad-bg)"/>
          <!-- Dappled light -->
          <ellipse cx="120" cy="55" rx="50" ry="35" fill="url(#ad-dapple)"/>
          <ellipse cx="310" cy="50" rx="45" ry="30" fill="url(#ad-dapple)"/>
          <!-- Forest floor -->
          <ellipse cx="200" cy="285" rx="230" ry="28" fill="#4a3a25" opacity="0.25"/>
          <ellipse cx="200" cy="280" rx="200" ry="18" fill="#5a4a30" opacity="0.2"/>
          <!-- Fallen leaves -->
          <g opacity="0.45">
            <ellipse cx="75" cy="276" rx="14" ry="4.5" fill="#b87830" transform="rotate(-12 75 276)"/>
            <ellipse cx="320" cy="278" rx="12" ry="4" fill="#c89830" transform="rotate(8 320 278)"/>
            <ellipse cx="140" cy="280" rx="10" ry="3.5" fill="#c4a040" transform="rotate(-18 140 280)"/>
            <ellipse cx="260" cy="275" rx="11" ry="4" fill="#a87828" transform="rotate(14 260 275)"/>
            <ellipse cx="195" cy="282" rx="13" ry="4" fill="#a07028" transform="rotate(3 195 282)"/>
          </g>
          <!-- Moss patches -->
          <g opacity="0.4">
            <circle cx="60" cy="272" r="7" fill="#3a7a28"/>
            <circle cx="70" cy="269" r="4" fill="#4a8a38"/>
            <circle cx="340" cy="271" r="6" fill="#3a7a28"/>
            <circle cx="350" cy="268" r="4" fill="#4a8a38"/>
          </g>
          <!-- ===== FAIRY RING OF AMETHYST DECEIVERS ===== -->
          <g filter="url(#ad-shadow)">
            <!-- === Mushroom A (center-left, hero, tallest) === -->
            <path d="M178 278 Q175 258 174 242 Q174 228 177 218 Q179 212 184 208 L196 208 Q201 212 203 218 Q206 228 206 242 Q205 258 202 278 Z" fill="url(#ad-stem1)"/>
            <g stroke="#9060B0" stroke-width="0.4" fill="none" opacity="0.25">
              <path d="M183 270 Q182 250 183 230 Q183 218 185 212"/>
              <path d="M190 274 Q190 252 190 232 Q190 218 190 210"/>
              <path d="M197 270 Q198 250 197 230 Q197 218 195 212"/>
            </g>
            <ellipse cx="190" cy="206" rx="32" ry="5" fill="url(#ad-gills)"/>
            <g stroke="#8040A0" stroke-width="0.3" fill="none" opacity="0.3">
              <line x1="165" y1="205" x2="215" y2="205"/>
              <line x1="168" y1="207" x2="212" y2="207"/>
              <line x1="170" y1="203" x2="210" y2="203"/>
            </g>
            <path d="M155 202 Q158 178 170 164 Q180 154 190 151 Q200 154 210 164 Q222 178 225 202 Z" fill="url(#ad-cap1)"/>
            <path d="M172 165 Q182 156 190 154 Q196 155 202 158 Q192 153 182 162 Q174 172 170 185 Z" fill="url(#ad-cap-shine)"/>
            <path d="M165 185 Q180 175 190 172 Q200 175 215 185" stroke="#D8B0F8" stroke-width="0.5" fill="none" opacity="0.15"/>
            <path d="M158 198 Q170 194 190 192 Q210 194 222 198" stroke="#6A1B8E" stroke-width="0.6" fill="none" opacity="0.25"/>

            <!-- === Mushroom B (center-right, second tallest) === -->
            <path d="M218 277 Q216 260 215 248 Q215 237 217 229 Q219 224 223 221 L233 221 Q237 224 239 229 Q241 237 241 248 Q240 260 238 277 Z" fill="url(#ad-stem2)"/>
            <g stroke="#9060B0" stroke-width="0.35" fill="none" opacity="0.2">
              <path d="M224 272 Q223 252 224 238 Q224 228 225 224"/>
              <path d="M232 272 Q233 252 232 238 Q232 228 231 224"/>
            </g>
            <ellipse cx="228" cy="219" rx="26" ry="4" fill="url(#ad-gills)"/>
            <path d="M199 216 Q203 196 213 185 Q221 178 228 176 Q235 178 243 185 Q253 196 257 216 Z" fill="url(#ad-cap2)"/>
            <path d="M215 186 Q223 180 228 178 Q233 180 238 183 Q228 177 218 188 Z" fill="#D8A0F0" opacity="0.25"/>
            <path d="M205 208 Q218 200 228 198 Q238 200 251 208" stroke="#D8B0F8" stroke-width="0.4" fill="none" opacity="0.12"/>

            <!-- === Mushroom C (left, medium) === -->
            <path d="M124 280 Q123 268 123 258 Q123 250 124 244 L132 244 Q133 250 133 258 Q133 268 132 280 Z" fill="url(#ad-stem1)"/>
            <ellipse cx="128" cy="242" rx="20" ry="3.5" fill="url(#ad-gills)"/>
            <path d="M106 240 Q110 224 120 216 Q126 213 128 212 Q130 213 136 216 Q146 224 150 240 Z" fill="url(#ad-cap1)"/>
            <path d="M121 218 Q126 214 128 213 Q131 214 134 217 Q128 213 122 220 Z" fill="#D8A0F0" opacity="0.2"/>

            <!-- === Mushroom D (right, medium) === -->
            <path d="M278 279 Q276 268 276 260 Q276 254 277 248 L285 248 Q286 254 286 260 Q286 268 284 279 Z" fill="url(#ad-stem2)"/>
            <ellipse cx="281" cy="246" rx="18" ry="3" fill="url(#ad-gills)"/>
            <path d="M261 244 Q265 230 274 223 Q279 220 281 220 Q283 220 288 223 Q297 230 301 244 Z" fill="url(#ad-cap2)"/>
            <path d="M275 225 Q279 221 281 221 Q284 222 287 225 Q281 220 276 227 Z" fill="#D8A0F0" opacity="0.2"/>

            <!-- === Mushroom E (far left, small, young) === -->
            <path d="M78 282 Q77 276 77 271 Q77 267 78 264 L84 264 Q85 267 85 271 Q85 276 84 282 Z" fill="url(#ad-stem1)"/>
            <path d="M67 262 Q70 254 77 249 Q80 248 81 248 Q82 248 85 249 Q92 254 95 262 Z" fill="url(#ad-cap1)"/>

            <!-- === Mushroom F (far right, small, young) === -->
            <path d="M320 281 Q319 275 319 270 Q319 267 320 264 L326 264 Q327 267 327 270 Q327 275 326 281 Z" fill="url(#ad-stem2)"/>
            <path d="M310 262 Q312 254 319 249 Q322 248 323 248 Q324 248 327 249 Q334 254 336 262 Z" fill="url(#ad-cap2)"/>

            <!-- === Mushroom G (behind center, peeking, tiny) === -->
            <path d="M200 272 Q199 267 199 263 Q199 261 200 259 L204 259 Q205 261 205 263 Q205 267 204 272 Z" fill="url(#ad-stem2)" opacity="0.6"/>
            <path d="M193 258 Q195 252 200 249 Q202 248 202 248 Q204 249 207 252 Q209 258 Z" fill="url(#ad-cap1)" opacity="0.6"/>

            <!-- === Mushroom H (between left and center, tiny baby) === -->
            <path d="M152 282 Q151 278 151 275 Q151 273 152 271 L156 271 Q157 273 157 275 Q157 278 156 282 Z" fill="url(#ad-stem1)" opacity="0.5"/>
            <path d="M146 270 Q148 265 152 263 Q154 262 154 262 Q156 263 158 265 Q160 270 Z" fill="url(#ad-cap2)" opacity="0.5"/>

            <!-- === Mushroom I (between right and far right, tiny) === -->
            <path d="M300 281 Q299 277 299 274 Q299 272 300 270 L304 270 Q305 272 305 274 Q305 277 304 281 Z" fill="url(#ad-stem2)" opacity="0.5"/>
            <path d="M294 269 Q296 264 300 262 Q302 261 302 261 Q304 262 306 264 Q308 269 Z" fill="url(#ad-cap1)" opacity="0.5"/>
          </g>
        </svg>
      SVG
    }
  }.freeze

  def self.all
    CATALOG
  end

  def self.find(key)
    CATALOG[key.to_s.downcase]
  end

  def self.keys
    CATALOG.keys
  end

  # Returns localized text for a species field
  def self.localized(species, field, lang)
    if lang == "ro"
      ro_key = "#{field}_ro".to_sym
      species[ro_key] || species[field]
    else
      species[field]
    end
  end
end
