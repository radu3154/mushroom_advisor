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
      rain_range: { ideal_min: 10, ideal_max: 30, abs_min: 3, abs_max: 60 },
      delay_days: { ideal_min: 3, ideal_max: 5, abs_min: 1, abs_max: 8 },
      habitat: [
        "\u{1F34E} Old apple and pear orchards",
        "\u{1F333} Near ash, elm, and tulip poplar trees",
        "\u{1F525} Disturbed soil and burn sites",
        "\u{2600}\u{FE0F} South-facing slopes with morning sun",
        "\u{1F4A7} Sandy loam soils with good drainage"
      ],
      habitat_ro: [
        "\u{1F34E} Livezi vechi de meri și peri",
        "\u{1F333} Lângă frăsini, ulmi și plopi",
        "\u{1F525} Sol deranjat și zone arse",
        "\u{2600}\u{FE0F} Versanți cu expunere sudică și soare dimineața",
        "\u{1F4A7} Soluri nisipoase cu drenaj bun"
      ],
      tips: [
        "\u{1F327}\u{FE0F} Check 3-5 days after a good spring rain",
        "\u{1F338} Look when lilacs bloom and soil hits 10C",
        "\u{1F525} Burn sites from the previous year are gold",
        "\u{1F305} Early morning light makes them easier to spot"
      ],
      tips_ro: [
        "\u{1F327}\u{FE0F} Verifică la 3-5 zile după o ploaie bună de primăvară",
        "\u{1F338} Caută când înfloresc liliacul și solul atinge 10°C",
        "\u{1F525} Zonele arse din anul precedent sunt de aur",
        "\u{1F305} Lumina dimineții le face mai ușor de observat"
      ],
      color: "#8B6914",
      gradient_from: "#a67c28",
      gradient_to: "#d4a843",
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
      temp_range: { ideal_min: 12, ideal_max: 22, abs_min: 8, abs_max: 28 },
      rain_range: { ideal_min: 15, ideal_max: 40, abs_min: 5, abs_max: 80 },
      delay_days: { ideal_min: 5, ideal_max: 10, abs_min: 3, abs_max: 14 },
      habitat: [
        "\u{1F332} Mixed conifer and deciduous forests",
        "\u{1F333} Under oak, spruce, pine, and birch trees",
        "\u{1FAB4} Mossy forest floors with dappled shade",
        "\u{1F304} Edges of forest clearings",
        "\u{1F342} Well-drained slopes with leaf litter"
      ],
      habitat_ro: [
        "\u{1F332} Păduri mixte de conifere și foioase",
        "\u{1F333} Sub stejari, molizi, pini și mesteceni",
        "\u{1FAB4} Podeaua pădurii cu mușchi și umbră",
        "\u{1F304} Marginile poienilor",
        "\u{1F342} Versanți cu drenaj bun și frunze căzute"
      ],
      tips: [
        "\u{26C8}\u{FE0F} Best 5-10 days after sustained summer rain",
        "\u{1F32B}\u{FE0F} Warm humid mornings are ideal hunting time",
        "\u{1F4CD} Return to known spots -- porcini are loyal",
        "\u{1F332} Check under older trees with thick canopy"
      ],
      tips_ro: [
        "\u{26C8}\u{FE0F} Cel mai bine la 5-10 zile după ploaie de vară",
        "\u{1F32B}\u{FE0F} Diminețile calde și umede sunt ideale",
        "\u{1F4CD} Revino la locurile cunoscute — hribii sunt fideli",
        "\u{1F332} Verifică sub copacii bătrâni cu coroană deasă"
      ],
      color: "#8B4513",
      gradient_from: "#6b3410",
      gradient_to: "#a0522d",
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
      season_months: [6, 7, 8, 9],
      temp_range: { ideal_min: 15, ideal_max: 25, abs_min: 10, abs_max: 30 },
      rain_range: { ideal_min: 20, ideal_max: 50, abs_min: 8, abs_max: 90 },
      delay_days: { ideal_min: 2, ideal_max: 5, abs_min: 1, abs_max: 7 },
      habitat: [
        "\u{1FAB4} Mossy hardwood and mixed forests",
        "\u{1F333} Near oak, beech, and birch trees",
        "\u{1F4A7} Damp, shaded ravines and stream banks",
        "\u{1F6B6} Paths and trails through old-growth forest",
        "\u{1F33F} Under blueberry and fern cover"
      ],
      habitat_ro: [
        "\u{1FAB4} Păduri de foioase și mixte cu mușchi",
        "\u{1F333} Lângă stejari, fagi și mesteceni",
        "\u{1F4A7} Ravene umede și maluri de pâraie",
        "\u{1F6B6} Poteci prin păduri bătrâne",
        "\u{1F33F} Sub afini și ferigi"
      ],
      tips: [
        "\u{2614} Look 2-5 days after warm summer rain",
        "\u{1FAB4} Follow moss trails -- chanterelles love moss",
        "\u{2728} Their golden color pops on rainy mornings",
        "\u{1F91E} Gently twist and pull, don't cut -- they regrow"
      ],
      tips_ro: [
        "\u{2614} Caută la 2-5 zile după ploaie caldă de vară",
        "\u{1FAB4} Urmează cărările cu mușchi — gălbiorii adoră mușchiul",
        "\u{2728} Culoarea lor aurie se vede bine în dimineți ploioase",
        "\u{1F91E} Răsucește ușor și trage, nu tăia — cresc din nou"
      ],
      color: "#DAA520",
      gradient_from: "#c9941a",
      gradient_to: "#f0c040",
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
