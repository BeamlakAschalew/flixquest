# Firebase Remote Config: logos and occasional themes

This file documents every Remote Config value used by the occasional-theme
system. The theme catalog is intentionally one JSON string so a single publish
activates a consistent catalog on every client.

## Remote Config parameters

| Parameter | Firebase type | Default | Purpose |
| --- | --- | --- | --- |
| `occasional_theme` | String | `{"enabled":false}` | Versioned theme catalog described below. |
| `app_logo_url` | String | Empty | General in-app logo URL when no active theme supplies one. |
| `cinemax_logo` | String | `default` | Legacy logo fallback. Keep only while older clients need it. |

An active theme's `logo_url` wins over `app_logo_url`, which wins over
`cinemax_logo`, which wins over the bundled logo. The native Android/iOS launch
splash remains bundled because it appears before Firebase initializes.

## Ready-to-paste complete catalog

Create `occasional_theme` as a **String**, paste this JSON as its value, replace
the logo URLs and dates, then publish. Overlapping dates are supported.

```json
{
  "schema_version": 2,
  "enabled": true,
  "allow_user_selection": true,
  "effects_enabled": true,
  "allow_user_effects_toggle": true,
  "default_theme_id": "",
  "themes": [
    {
      "id": "christmas",
      "display_name": "Christmas",
      "description": "A warm Christmas celebration",
      "enabled": true,
      "user_selectable": true,
      "priority": 80,
      "logo_url": "https://example.com/logos/christmas.png",
      "starts_at": "2026-12-01T00:00:00Z",
      "ends_at": "2027-01-07T23:59:59Z",
      "effect": {
        "enabled": true,
        "type": "snow",
        "density": 34,
        "speed": 0.75,
        "opacity": 0.62,
        "colors": ["#FFFFFF", "#DCEEFF", "#EAF7FF"]
      }
    },
    {
      "id": "ethiopian_new_year",
      "display_name": "Ethiopian New Year",
      "description": "Enkutatash and the season of Adey Abeba",
      "enabled": true,
      "user_selectable": true,
      "priority": 90,
      "logo_url": "https://example.com/logos/enkutatash.svg",
      "starts_at": "2026-09-01T00:00:00+03:00",
      "ends_at": "2026-09-20T23:59:59+03:00",
      "effect": {
        "enabled": true,
        "type": "adey_flowers",
        "density": 26,
        "speed": 0.7,
        "opacity": 0.55,
        "colors": ["#F9A825", "#FFD740", "#2E7D32"]
      }
    },
    {
      "id": "new_year",
      "display_name": "New Year",
      "enabled": true,
      "user_selectable": true,
      "priority": 100,
      "logo_url": "https://example.com/logos/new-year.png",
      "starts_at": "2026-12-28T00:00:00Z",
      "ends_at": "2027-01-03T23:59:59Z",
      "effect": {
        "enabled": true,
        "type": "fireworks",
        "density": 12,
        "speed": 0.9,
        "opacity": 0.7
      }
    },
    {
      "id": "halloween",
      "display_name": "Halloween",
      "enabled": true,
      "user_selectable": true,
      "priority": 70,
      "logo_url": "https://example.com/logos/halloween.png",
      "starts_at": "2026-10-20T00:00:00Z",
      "ends_at": "2026-11-02T23:59:59Z",
      "effect": {
        "enabled": true,
        "type": "bats",
        "density": 14,
        "speed": 0.65,
        "opacity": 0.48
      }
    },
    {
      "id": "valentines",
      "display_name": "Valentine's Day",
      "enabled": true,
      "user_selectable": true,
      "priority": 60,
      "logo_url": "https://example.com/logos/valentines.png",
      "starts_at": "2027-02-07T00:00:00Z",
      "ends_at": "2027-02-15T23:59:59Z",
      "effect": {
        "enabled": true,
        "type": "hearts",
        "density": 20,
        "speed": 0.6,
        "opacity": 0.48
      }
    },
    {
      "id": "easter",
      "display_name": "Easter",
      "enabled": true,
      "user_selectable": true,
      "priority": 55,
      "logo_url": "https://example.com/logos/easter.png",
      "starts_at": "2027-03-22T00:00:00Z",
      "ends_at": "2027-03-30T23:59:59Z",
      "effect": {
        "enabled": true,
        "type": "candy_eggs",
        "density": 20,
        "speed": 0.6,
        "opacity": 0.5
      }
    },
    {
      "id": "eid",
      "display_name": "Eid",
      "enabled": true,
      "user_selectable": true,
      "priority": 75,
      "logo_url": "https://example.com/logos/eid.svg",
      "starts_at": "2027-03-08T00:00:00Z",
      "ends_at": "2027-03-13T23:59:59Z",
      "effect": {
        "enabled": true,
        "type": "stars",
        "density": 24,
        "speed": 0.55,
        "opacity": 0.58,
        "colors": ["#D4AF37", "#FFF8E1", "#00897B"]
      }
    },
    {
      "id": "diwali",
      "display_name": "Diwali",
      "enabled": true,
      "user_selectable": true,
      "priority": 65,
      "logo_url": "https://example.com/logos/diwali.png",
      "starts_at": "2026-11-01T00:00:00+05:30",
      "ends_at": "2026-11-10T23:59:59+05:30",
      "effect": {
        "enabled": true,
        "type": "sparkles",
        "density": 30,
        "speed": 0.7,
        "opacity": 0.64
      }
    }
  ]
}
```

The dates above are configuration examples, not a permanent holiday calendar.
Update movable observances such as Easter, Eid, and Diwali each year before
publishing.

## Catalog configuration

| Field | Type | Default | Behavior |
| --- | --- | --- | --- |
| `schema_version` | Integer | `2` | Current schema version. |
| `enabled` | Boolean | `false` | Master switch. When false, no occasional theme or effect is used. |
| `allow_user_selection` | Boolean | `false` | Shows Seasonal theme in handheld and TV settings. |
| `effects_enabled` | Boolean | `true` | Master switch for every vector effect. Colors and logos still work when false. |
| `allow_user_effects_toggle` | Boolean | `false` | Lets users disable decorative effects in settings. |
| `default_theme_id` | String | Empty | Automatic mode prefers this active ID. Empty uses priority. |
| `themes` | Array | Empty | Up to 24 definitions; duplicate IDs use the last definition. |

### Overlap and selection rules

1. Only themes with `enabled: true` inside their start/end window are active.
2. A user's explicit active selection wins when selection is allowed.
3. Otherwise Automatic uses an active `default_theme_id`, if supplied.
4. Otherwise the highest `priority` wins.
5. Equal priorities are resolved by ID alphabetically for deterministic results.
6. Removed, disabled, or expired user choices return to Automatic.

### User controls

When the catalog is enabled, **Settings → Appearance → Seasonal themes** is a
local master switch. It defaults to on. Turning it off removes the occasional
palette, occasional logo, and decorative effect while preserving the selected
theme for later. On TV, the same switch is available under **Settings →
Seasonal themes**.

When `allow_user_effects_toggle` is true, **Seasonal effects** is a separate
switch that disables only snow, flowers, treats, fireworks, and other decorations while
keeping the seasonal colors and logo.

## Theme configuration

| Field | Type | Default | Behavior |
| --- | --- | --- | --- |
| `id` | String | Required | Stable lowercase identifier. Built-in IDs are listed below. |
| `display_name` | String | Preset/name derived from ID | User-facing label in settings. |
| `description` | String | Empty | Optional catalog description reserved for richer selectors. |
| `enabled` | Boolean | `false` | Switch for this definition. |
| `user_selectable` | Boolean | `true` | Whether this active theme appears as a manual choice. |
| `priority` | Integer | `0` | Automatic overlap priority, clamped from `-1000` to `1000`. |
| `logo_url` | String | Empty | Theme logo; HTTPS PNG/WebP/JPEG/GIF/SVG recommended. |
| `colors` | Array of two hex colors | Required for custom IDs | Primary and complementary secondary colors. `#RRGGBB` or `#AARRGGBB`. |
| `primary_color` | Hex color | Preset | `#RRGGBB` or `#AARRGGBB`. |
| `secondary_color` | Hex color | Preset | Secondary palette color. |
| `tertiary_color` | Hex color | Preset/derived | Optional third accent; custom themes derive it from `colors`. |
| `light_background_color` | Hex color | Preset/derived | Optional page surface in Light mode. |
| `dark_background_color` | Hex color | Preset/derived | Optional page surface in Dark/AMOLED mode. |
| `starts_at` | ISO-8601 string | No lower bound | UTC or an explicit offset such as `+03:00`. |
| `ends_at` | ISO-8601 string | No upper bound | Inclusive activation endpoint. |
| `effect` | Object | Disabled preset effect | Optional vector effect configuration. |

Malformed or structurally invalid JSON is not persisted and leaves the last
known-good catalog active. An invalid date or reversed date range removes that
theme from the catalog. Invalid colors on a built-in ID fall back to its
hardcoded preset. An enabled custom ID requires two distinct valid colors; an
invalid custom entry is ignored, allowing another valid built-in entry in the
same catalog to act as the fallback. Unknown effect names use the preset type.
An unreachable/invalid logo URL falls back to the next logo source without
breaking the page.

## Built-in theme IDs and defaults

| ID | Aliases | Default effect | Palette character |
| --- | --- | --- | --- |
| `christmas` | `xmas` | `snow` | Red, evergreen, gold |
| `ethiopian_new_year` | `ethiopian-new-year`, `enkutatash` | `adey_flowers` | Falling leaves with miniature Adey flowers |
| `new_year` | `new-year` | `fireworks` | Gold, indigo, magenta |
| `halloween` | — | `bats` | Orange, purple, near-black |
| `valentines` | `valentines_day`, `valentine` | `hearts` | Rose and pink |
| `easter` | — | `candy_eggs` | Falling leaves, wrapped candies, and decorated eggs |
| `eid` | `eid_al_fitr`, `eid_al_adha` | `stars` | Emerald, gold, violet |
| `diwali` | — | `sparkles` | Saffron, pink, purple |

Any other ID is a custom theme. Supply two distinct complementary colors using
`colors`, or the equivalent `primary_color` and `secondary_color` fields. The
app derives a tertiary accent and readable Light/Dark surfaces from that pair;
you can still override those derived values explicitly. The default custom
effect type is `confetti`.

## Effect configuration

Effects are vector shapes drawn by Flutter; no image assets or downloads are
required. They ignore pointer input, stop while the app is backgrounded, and
are automatically hidden when the operating system requests reduced motion.

| Field | Type | Default | Valid values / limits |
| --- | --- | --- | --- |
| `enabled` | Boolean | `false` | Per-theme effect switch. |
| `type` | String | Theme preset | `none`, `snow`, `confetti`, `fireworks`, `petals`, `candy_eggs`, `adey_flowers`, `hearts`, `stars`, `bats`, `sparkles` |
| `density` | Integer | `28` | Clamped to `4`–`80`; use `8`–`36` for TVs and phones. |
| `speed` | Number | `1.0` | Clamped to `0.2`–`3.0`. |
| `opacity` | Number | `0.65` | Clamped to `0.1`–`1.0`. |
| `colors` | Array of hex colors | Theme-aware colors | Optional, first eight valid colors are used. |

To keep a seasonal palette/logo without animation:

```json
"effect": { "enabled": false, "type": "snow" }
```

To disable every effect immediately while preserving all seasonal themes:

```json
"effects_enabled": false
```

## Custom campaign example

```json
{
  "id": "flixquest_anniversary",
  "display_name": "FlixQuest Anniversary",
  "enabled": true,
  "user_selectable": true,
  "priority": 500,
  "colors": ["#7B1FA2", "#00897B"],
  "logo_url": "https://example.com/logos/anniversary.svg",
  "starts_at": "2026-10-01T00:00:00Z",
  "ends_at": "2026-10-15T23:59:59Z",
  "effect": {
    "enabled": true,
    "type": "confetti",
    "density": 30,
    "speed": 0.8,
    "opacity": 0.55,
    "colors": ["#7B1FA2", "#00897B", "#F9A825"]
  }
}
```

Add that object inside the catalog's `themes` array.

For a safe custom-event rollout, keep a built-in definition (for example
`halloween`) in the same catalog with a lower priority and the same activation
window. If the custom entry is invalid, the parser drops it and automatic mode
resolves the built-in preset. If the entire new value is malformed, the app
keeps the previously persisted catalog instead.

## Safe rollout and rollback

1. Publish the catalog with `enabled: false` to validate delivery first.
2. Enable individual themes and confirm their date windows and logo URLs.
3. Set catalog `enabled: true`; use Firebase targeting/percentage conditions if
   you want a staged rollout.
4. Roll back instantly with `{"schema_version":2,"enabled":false,"themes":[]}`.

Clients persist the last successfully activated remote catalog for offline
startup and listen for real-time Remote Config activation events. Start/end
boundaries are also scheduled locally, so an open app changes theme without a
restart or another fetch.

## Legacy single-theme format

Older values still work and are migrated in memory:

```json
{
  "enabled": true,
  "id": "christmas",
  "logo_url": "https://example.com/christmas.png",
  "starts_at": "2026-12-01T00:00:00Z",
  "ends_at": "2027-01-07T23:59:59Z"
}
```

Legacy format does not expose user selection. Move to schema version 2 for
overlaps, selection, priorities, and global effect controls.
