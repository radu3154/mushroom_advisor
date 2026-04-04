module IconHelper
  # Inline SVG icons in earthy-but-colorful style.
  # Expanded palette: forest greens, warm amber/gold, rusty orange, sky blue, berry pink, earth brown
  # All icons are 20x20 viewBox, rendered as inline <svg> tags.

  ICONS = {
    # --- UI ---
    mushroom: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><defs><linearGradient id="mcap" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#d4a843"/><stop offset="100%" stop-color="#a07020"/></linearGradient></defs><ellipse cx="10" cy="8" rx="9" ry="7" fill="url(#mcap)"/><circle cx="6" cy="6" r="1.3" fill="#e8c96e" opacity=".5"/><circle cx="12" cy="5" r="1" fill="#e8c96e" opacity=".45"/><circle cx="9" cy="9" r=".9" fill="#e8c96e" opacity=".35"/><rect x="8" y="12" width="4" height="6" rx="1.5" fill="#f5ecd8"/></svg>',

    amanita: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><defs><linearGradient id="amcap" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#e74c3c"/><stop offset="100%" stop-color="#b71c1c"/></linearGradient></defs><ellipse cx="10" cy="8" rx="9" ry="7" fill="url(#amcap)"/><circle cx="6" cy="5.5" r="1.4" fill="#fff" opacity=".85"/><circle cx="12.5" cy="5" r="1.1" fill="#fff" opacity=".8"/><circle cx="9" cy="9" r="1" fill="#fff" opacity=".75"/><circle cx="14" cy="8" r=".8" fill="#fff" opacity=".65"/><circle cx="4.5" cy="8.5" r=".7" fill="#fff" opacity=".6"/><circle cx="10" cy="3.5" r=".9" fill="#fff" opacity=".7"/><rect x="8" y="12" width="4" height="6" rx="1.5" fill="#d9c9a0" stroke="#bfae85" stroke-width=".5"/><ellipse cx="10" cy="12.5" rx="5" ry="1" fill="#c9a96e" opacity=".35"/></svg>',

    pin: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 1C6.7 1 4 3.7 4 7c0 4.5 6 11 6 11s6-6.5 6-11c0-3.3-2.7-6-6-6z" fill="#c0392b"/><circle cx="10" cy="7" r="2.5" fill="#f5e6c8"/></svg>',

    clock: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><circle cx="10" cy="10" r="8" fill="none" stroke="#d4a843" stroke-width="1.8"/><circle cx="10" cy="10" r="6.5" fill="#fdf6e3"/><line x1="10" y1="10" x2="10" y2="5.5" stroke="#2d5016" stroke-width="1.5" stroke-linecap="round"/><line x1="10" y1="10" x2="13.5" y2="10" stroke="#c0392b" stroke-width="1.2" stroke-linecap="round"/><circle cx="10" cy="10" r=".8" fill="#2d5016"/></svg>',

    rain_cloud: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M5.5 11C3.6 11 2 9.7 2 8c0-1.5 1.2-2.8 2.8-3 .5-2 2.3-3.5 4.5-3.5 2.4 0 4.3 1.8 4.6 4.1C15.6 5.9 17 7.3 17 9c0 1.7-1.3 3-3 3H5.5z" fill="#8ba8c4"/><line x1="6" y1="13.5" x2="5" y2="17" stroke="#4a90d9" stroke-width="1.2" stroke-linecap="round"/><line x1="10" y1="13.5" x2="9" y2="17" stroke="#4a90d9" stroke-width="1.2" stroke-linecap="round"/><line x1="14" y1="13.5" x2="13" y2="17" stroke="#4a90d9" stroke-width="1.2" stroke-linecap="round"/></svg>',

    checkmark: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><circle cx="10" cy="10" r="9" fill="#2d8a4e"/><path d="M6 10l2.5 3L14 7" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',

    # --- Decorative header ---
    leaf_autumn: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em"><path d="M10 2C6 2 3 6 3 10c0 3 2 5 4 6l1-1C6 13 5 11 5 9c0-3 2-5 5-5V2z" fill="#e67e22"/><path d="M10 2c4 0 7 4 7 8 0 3-2 5-4 6l-1-1c2-2 3-4 3-6 0-3-2-5-5-5V2z" fill="#c0392b"/><line x1="10" y1="4" x2="10" y2="17" stroke="#8B5a1e" stroke-width=".8"/></svg>',

    herb: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em"><path d="M10 18V6" stroke="#2d7016" stroke-width="1.2"/><path d="M10 6C8 4 5 4 3 6c2-1 4 0 5 2" fill="#5cb85c" stroke="#2d7016" stroke-width=".6"/><path d="M10 9c2-2 5-2 7 0-2-1-4 0-5 2" fill="#7aca7a" stroke="#2d7016" stroke-width=".6"/><path d="M10 12C8 10 5 10 3 12c2-1 4 0 5 2" fill="#5cb85c" stroke="#2d7016" stroke-width=".6"/></svg>',

    tree_conifer: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em"><polygon points="10,2 4,10 6,10 3,15 7,15 5,18 15,18 13,15 17,15 14,10 16,10" fill="#2d7a30"/><polygon points="10,2 7,8 13,8" fill="#3da843" opacity=".5"/><rect x="9" y="16" width="2" height="3" fill="#8B6534"/></svg>',

    leaf_flutter: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em"><path d="M15 3C11 3 7 5 5 9c-1 2-1 5 0 7 1-3 3-5 6-6 2-1 4-1 6 0-1-2-2-5-2-7z" fill="#5cb85c"/><path d="M5 16c1-4 4-7 8-8" fill="none" stroke="#2d7016" stroke-width=".8"/></svg>',

    # --- Habitat icons ---
    apple: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><circle cx="10" cy="11" r="7" fill="#e74c3c"/><circle cx="8" cy="9" r="2" fill="#f5766e" opacity=".4"/><ellipse cx="10" cy="5.5" rx="1.2" ry="2" fill="#2d8a30"/><path d="M10 4c1-2 3-3 4-2" fill="none" stroke="#8B5a1e" stroke-width=".8"/></svg>',

    tree_deciduous: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><circle cx="10" cy="7" r="6.5" fill="#5cb85c"/><circle cx="7" cy="8" r="3.5" fill="#3da843"/><circle cx="13" cy="8" r="3.5" fill="#3da843"/><circle cx="10" cy="5" r="3.5" fill="#6dce6d"/><rect x="9" y="13" width="2" height="5" rx=".5" fill="#8B6534"/></svg>',

    fire: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 2c0 3-4 5-4 9 0 3.3 2 5 4 5s4-1.7 4-5c0-4-4-6-4-9z" fill="#e67e22"/><path d="M10 6c0 2-3 4-3 7 0 2 1.5 3 3 3s3-1 3-3c0-3-3-5-3-7z" fill="#e74c3c"/><path d="M10 10c0 1.5-1.5 2.5-1.5 4s.7 2 1.5 2 1.5-.5 1.5-2-1.5-2.5-1.5-4z" fill="#f9c74f"/></svg>',

    sun: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><circle cx="10" cy="10" r="4" fill="#f9c74f"/><circle cx="10" cy="10" r="2.5" fill="#f9a825" opacity=".5"/><g stroke="#f9a825" stroke-width="1.5" stroke-linecap="round"><line x1="10" y1="1.5" x2="10" y2="4"/><line x1="10" y1="16" x2="10" y2="18.5"/><line x1="1.5" y1="10" x2="4" y2="10"/><line x1="16" y1="10" x2="18.5" y2="10"/><line x1="4" y1="4" x2="5.8" y2="5.8"/><line x1="14.2" y1="14.2" x2="16" y2="16"/><line x1="4" y1="16" x2="5.8" y2="14.2"/><line x1="14.2" y1="5.8" x2="16" y2="4"/></g></svg>',

    droplet: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 2C10 2 4 9 4 13c0 3.3 2.7 5 6 5s6-1.7 6-5c0-4-6-11-6-11z" fill="#4a90d9"/><ellipse cx="8" cy="12" rx="1.8" ry="2.5" fill="#7ab8f5" opacity=".4"/></svg>',

    rain_heavy: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M5 9C3.3 9 2 7.9 2 6.5 2 5.2 3 4 4.3 3.8 4.7 2.2 6.2 1 8 1c2 0 3.6 1.5 3.8 3.4C13.2 4.6 14.5 5.8 14.5 7.3 14.5 8.8 13.3 10 11.8 10H5z" fill="#8ba8c4"/><line x1="5" y1="11.5" x2="3.5" y2="16" stroke="#4a90d9" stroke-width="1.3" stroke-linecap="round"/><line x1="8.5" y1="11.5" x2="7" y2="16" stroke="#4a90d9" stroke-width="1.3" stroke-linecap="round"/><line x1="12" y1="11.5" x2="10.5" y2="16" stroke="#4a90d9" stroke-width="1.3" stroke-linecap="round"/><line x1="6.5" y1="15" x2="5.5" y2="18" stroke="#6aaef0" stroke-width="1" stroke-linecap="round"/><line x1="10" y1="15" x2="9" y2="18" stroke="#6aaef0" stroke-width="1" stroke-linecap="round"/></svg>',

    blossom: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><circle cx="10" cy="10" r="2.2" fill="#f9c74f"/><g fill="#f0a0c0" stroke="#d4789a" stroke-width=".4"><ellipse cx="10" cy="4.5" rx="2.2" ry="3.2"/><ellipse cx="10" cy="15.5" rx="2.2" ry="3.2"/><ellipse cx="4.5" cy="10" rx="3.2" ry="2.2"/><ellipse cx="15.5" cy="10" rx="3.2" ry="2.2"/></g></svg>',

    sunrise: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M2 14h16" stroke="#5cb85c" stroke-width="1.5"/><path d="M4 14c0-3.3 2.7-6 6-6s6 2.7 6 6" fill="#f9c74f" opacity=".35"/><circle cx="10" cy="10" r="2.5" fill="#f9a825" opacity=".6"/><g stroke="#f9a825" stroke-width="1.2" stroke-linecap="round"><line x1="10" y1="3" x2="10" y2="5.5"/><line x1="4.5" y1="9" x2="6.2" y2="10.2"/><line x1="15.5" y1="9" x2="13.8" y2="10.2"/><line x1="2.5" y1="14" x2="4" y2="12.5"/><line x1="17.5" y1="14" x2="16" y2="12.5"/></g></svg>',

    moss: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><ellipse cx="10" cy="16" rx="8" ry="3" fill="#5cb85c" opacity=".35"/><path d="M6 16c0-3 1-6 2-8" stroke="#2d7016" stroke-width="1" fill="none"/><path d="M10 16c0-4 0-7 1-10" stroke="#2d7016" stroke-width="1" fill="none"/><path d="M14 16c0-3-1-5-2-7" stroke="#2d7016" stroke-width="1" fill="none"/><circle cx="6" cy="8" r="2.5" fill="#5cb85c"/><circle cx="11" cy="5.5" r="3" fill="#3da843"/><circle cx="12.5" cy="9.5" r="2" fill="#7aca7a"/></svg>',

    clearing: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><rect x="1" y="14" width="18" height="4" rx="1" fill="#7aca7a" opacity=".3"/><polygon points="3,14 1,18 5,18" fill="#2d7a30"/><polygon points="17,14 15,18 19,18" fill="#2d7a30"/><circle cx="10" cy="6" r="3.5" fill="#f9c74f" opacity=".6"/><g stroke="#f9a825" stroke-width="1" stroke-linecap="round"><line x1="10" y1="1" x2="10" y2="2.5"/><line x1="14" y1="3" x2="13" y2="4"/><line x1="6" y1="3" x2="7" y2="4"/></g></svg>',

    fallen_leaf: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M3 7c2-4 7-6 12-5-1 5-4 9-9 11C4 13 3 10 3 7z" fill="#e67e22"/><path d="M15 2C12 5 8 9 6 13" fill="none" stroke="#c0392b" stroke-width=".8"/><path d="M9 6c-2 2-3 4-3 6" fill="none" stroke="#c0392b" stroke-width=".6"/><path d="M12 5c-1 2-2 5-3 7" fill="none" stroke="#c0392b" stroke-width=".6"/></svg>',

    storm: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M5.5 9C3.6 9 2 7.8 2 6.3 2 5 3 3.8 4.5 3.5 5 2 6.5 1 8.5 1c2.2 0 4 1.7 4.2 3.8C14.2 5 15.5 6.3 15.5 7.8c0 1.5-1.2 2.7-2.7 2.7H5.5z" fill="#7a8ea0"/><polygon points="10,10 8,14 10.5,14 8.5,18 13,13 10.5,13 12.5,10" fill="#f9c74f"/></svg>',

    fog: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M5 7C3.3 7 2 5.9 2 4.5S3.3 2 5 2c.3 0 .6 0 .8.1C6.5 1.4 7.4 1 8.5 1c1.5 0 2.8.9 3.3 2.2.3-.1.5-.2.7-.2 1.4 0 2.5 1.1 2.5 2.5S13.9 8 12.5 8H5z" fill="#8ba8c4" opacity=".7"/><line x1="3" y1="11" x2="17" y2="11" stroke="#8ba8c4" stroke-width="1.3" stroke-linecap="round" opacity=".6"/><line x1="5" y1="13.5" x2="15" y2="13.5" stroke="#a0bcd4" stroke-width="1.3" stroke-linecap="round" opacity=".5"/><line x1="4" y1="16" x2="16" y2="16" stroke="#b4cce0" stroke-width="1.3" stroke-linecap="round" opacity=".4"/></svg>',

    map_pin: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 1C7 1 4.5 3.5 4.5 6.5c0 4 5.5 10.5 5.5 10.5s5.5-6.5 5.5-10.5C15.5 3.5 13 1 10 1z" fill="#c0392b"/><circle cx="10" cy="6.5" r="2" fill="#f5e6c8"/></svg>',

    trail: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M4 18c2-4 3-7 6-10s5-5 6-7" fill="none" stroke="#8B6534" stroke-width="1.5" stroke-linecap="round" stroke-dasharray="2 2.5"/><circle cx="3" cy="7" r="2.5" fill="#5cb85c"/><circle cx="8" cy="4" r="2" fill="#3da843"/><circle cx="15" cy="10" r="2.5" fill="#7aca7a"/></svg>',

    fern: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 18V4" stroke="#2d7016" stroke-width="1"/><path d="M10 6L6 4M10 8L5 7M10 10L6 10M10 12L5 13" stroke="#5cb85c" stroke-width="1.2" stroke-linecap="round"/><path d="M10 6L14 4M10 8L15 7M10 10L14 10M10 12L15 13" stroke="#3da843" stroke-width="1.2" stroke-linecap="round"/><circle cx="10" cy="3" r="1.5" fill="#2d8a30"/></svg>',

    umbrella: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M3 10c0-3.9 3.1-7 7-7s7 3.1 7 7H3z" fill="#c0392b"/><path d="M3 10c0-3.9 3.1-7 7-7" fill="#d9534f" opacity=".4"/><line x1="10" y1="3" x2="10" y2="16" stroke="#8B6534" stroke-width="1.2"/><path d="M10 16c0 1.1-.9 2-2 2" fill="none" stroke="#8B6534" stroke-width="1.2" stroke-linecap="round"/></svg>',

    sparkle: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 2l1.5 5.5L17 9l-5.5 1.5L10 16l-1.5-5.5L3 9l5.5-1.5z" fill="#f9c74f"/><path d="M10 4l1 3.5L15 9l-4 1L10 14l-1-4L5 9l4-1z" fill="#f9a825" opacity=".5"/><circle cx="15" cy="4" r="1.2" fill="#f9c74f" opacity=".6"/><circle cx="5" cy="15" r="1" fill="#f9c74f" opacity=".5"/></svg>',

    hand_pick: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><path d="M10 2c0 0-3 2-3 5 0 1.5 1 2.5 2 3v6c0 1 .5 2 1 2s1-1 1-2V10c1-.5 2-1.5 2-3 0-3-3-5-3-5z" fill="#d4a843"/><path d="M7 10c-1 0-2 .5-2 1.5s1 2 2 2" fill="none" stroke="#c0392b" stroke-width=".9"/><path d="M13 10c1 0 2 .5 2 1.5s-1 2-2 2" fill="none" stroke="#c0392b" stroke-width=".9"/></svg>',

    snowflake: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><g stroke="#6aaef0" stroke-width="1.3" stroke-linecap="round"><line x1="10" y1="2" x2="10" y2="18"/><line x1="3" y1="6" x2="17" y2="14"/><line x1="3" y1="14" x2="17" y2="6"/><line x1="10" y1="2" x2="8" y2="4"/><line x1="10" y1="2" x2="12" y2="4"/><line x1="10" y1="18" x2="8" y2="16"/><line x1="10" y1="18" x2="12" y2="16"/><line x1="3" y1="6" x2="5" y2="4.5"/><line x1="3" y1="6" x2="4" y2="8"/><line x1="17" y1="14" x2="15" y2="15.5"/><line x1="17" y1="14" x2="16" y2="12"/></g></svg>',

    log: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><ellipse cx="16" cy="11" rx="3" ry="5" fill="#8B6534"/><rect x="3" y="6" width="13" height="10" rx="2" fill="#a07040"/><ellipse cx="3" cy="11" rx="3" ry="5" fill="#c0955a"/><circle cx="3.5" cy="9.5" r="1.2" fill="#8B6534" opacity=".5"/><circle cx="2.5" cy="12" r=".8" fill="#8B6534" opacity=".4"/><path d="M3 8.5c.5-.3 1-.3 1.5.1" fill="none" stroke="#8B5a1e" stroke-width=".5"/></svg>',

    # --- Mixed forest (conifer + deciduous) ---
    mixed_forest: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="1em" height="1em" style="vertical-align:-0.15em"><polygon points="6,3 2,12 4,12 1,16 11,16 8,12 10,12" fill="#2d7a30"/><polygon points="6,3 4,8 8,8" fill="#3da843" opacity=".4"/><circle cx="14" cy="8" r="4.5" fill="#5cb85c"/><circle cx="12.5" cy="7" r="2" fill="#7aca7a" opacity=".5"/><rect x="5" y="15" width="2" height="3" fill="#8B6534"/><rect x="13" y="12" width="2" height="6" rx=".5" fill="#8B6534"/></svg>',
  }.freeze

  def self.icon(name)
    ICONS[name.to_sym] || ""
  end
end
