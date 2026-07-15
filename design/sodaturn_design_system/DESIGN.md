---
name: SodaTurn Design System
colors:
  surface: '#fbf8fe'
  surface-dim: '#dcd9de'
  surface-bright: '#fbf8fe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f2f8'
  surface-container: '#f0edf2'
  surface-container-high: '#eae7ed'
  surface-container-highest: '#e4e1e7'
  on-surface: '#1b1b1f'
  on-surface-variant: '#454652'
  inverse-surface: '#303034'
  inverse-on-surface: '#f3f0f5'
  outline: '#757684'
  outline-variant: '#c5c5d4'
  surface-tint: '#4355b9'
  primary: '#24389c'
  on-primary: '#ffffff'
  primary-container: '#3f51b5'
  on-primary-container: '#cacfff'
  inverse-primary: '#bac3ff'
  secondary: '#006e2a'
  on-secondary: '#ffffff'
  secondary-container: '#5cfd80'
  on-secondary-container: '#00732c'
  tertiary: '#004a57'
  on-tertiary: '#ffffff'
  tertiary-container: '#006474'
  on-tertiary-container: '#63e3ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bac3ff'
  on-primary-fixed: '#00105c'
  on-primary-fixed-variant: '#293ca0'
  secondary-fixed: '#69ff87'
  secondary-fixed-dim: '#3ce36a'
  on-secondary-fixed: '#002108'
  on-secondary-fixed-variant: '#00531e'
  tertiary-fixed: '#a8edff'
  tertiary-fixed-dim: '#49d7f4'
  on-tertiary-fixed: '#001f26'
  on-tertiary-fixed-variant: '#004e5b'
  background: '#fbf8fe'
  on-background: '#1b1b1f'
  surface-variant: '#e4e1e7'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
---

## Brand & Style

The design system is engineered to transform a mundane office chore into a refreshing, communal ritual. The brand personality is **modern, friendly, and clean**, utilizing a **Material Design 3 (MD3)** foundation enhanced with playful, gamified elements. 

The aesthetic leans into **Corporate Modernism with a Tactile twist**, using soft elevations and vibrant accents to evoke a sense of clarity and "sparkle." The UI should feel as crisp as a freshly opened soda—effervescent, rewarding, and effortlessly functional. 

Key attributes:
- **Effervescent:** Using subtle motion and "bubbly" visual metaphors.
- **Reliable:** Grounded in a systematic indigo base to maintain professional office utility.
- **Rewarding:** High-contrast success states to celebrate "winners" of the rotation.

## Colors

The color palette is built around the **Indigo Refresh** primary, providing a stable, trustworthy foundation. This is contrasted by **Sparkling Mint**, used specifically for "action" moments, progress, and gamified highlights.

- **Primary (Indigo Refresh):** Used for key branding, active navigation states, and primary button containers.
- **Secondary (Sparkling Mint):** Reserved for high-energy interactions, success indicators, and "Winner" highlights.
- **Surface:** A high-clarity, cool-toned white (#FDFBFF) ensures the interface feels airy and hygienic.
- **Tonal Palettes:** Use MD3-style tonal palettes for containers (e.g., Primary Container at 90% lightness) to create soft differentiation between layout sections.

## Typography

This design system utilizes **Plus Jakarta Sans** exclusively. Its modern, geometric construction and slightly rounded apertures mirror the "bubbly" brand narrative while maintaining exceptional legibility for list-heavy office data.

- **Headlines:** Use Bold (700) weight for clear hierarchy.
- **Body Text:** Use Regular (400) for high readability in participant lists and logs.
- **Interactive Elements:** Labels for buttons and chips use SemiBold (600) to ensure they feel actionable and distinct from static text.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile-first interaction. 

- **Grid:** 4-column grid for mobile, 8-column for tablet. 
- **Rhythm:** A strict 4px/8px baseline grid ensures vertical harmony.
- **Margins:** 16px lateral margins on mobile to maximize content real estate while maintaining "breathable" whitespace.
- **Padding:** Internal card padding is standardized at 20px to accommodate larger corner radii without crowding the content.

## Elevation & Depth

Elevation in this design system is achieved through **Tonal Layers** and **Soft Ambient Shadows**. 

1.  **Level 0 (Surface):** Default background (#FDFBFF).
2.  **Level 1 (Cards/Containers):** A subtle +1dp shadow (blur 4px, 8% opacity Indigo tint) and a slightly darker tonal surface color.
3.  **Level 2 (Active/Floating):** Used for the FAB and active "Winner" cards, featuring a more pronounced +3dp shadow with a 12% Indigo-tinted shadow.
4.  **Glassmorphism (Special):** For "bubbly" progress overlays or modally-presented winners, use a backdrop blur (12px) with a semi-transparent Sparkling Mint tint (10% opacity).

## Shapes

The shape language is the core of the gamified feel. 

- **Cards:** Large **24px** corner radius to create a soft, friendly container for participant data and daily winners.
- **Buttons & Chips:** Fully **Pill-shaped (999px)** to reinforce the "Soda" theme—mimicking the rounded edges of a bottle or can.
- **Inputs:** 12px radius to balance the extreme roundness of buttons with the structural needs of form fields.

## Components

### Daily Winner Cards
Featured cards that highlight the person responsible for the rotation. These should use a **Primary Container** background color or a subtle **Sparkling Mint** gradient. Include a decorative "bubble" pattern overlay at 5% opacity to add texture.

### Participant Chips
Interactive elements for team members.
- **State:** Pill-shaped with an avatar leading icon. 
- **Inactive:** Outlined with a thin 1px Indigo-tinted border.
- **Active/Selected:** Solid Indigo Refresh background with white text.

### Generate FAB (Floating Action Button)
The primary "Generate Week" action.
- **Shape:** Large Pill or Circular.
- **Color:** Sparkling Mint (#00C853) with an Indigo icon to ensure maximum visibility and "clickability."
- **Elevation:** Level 3 shadow to appear "hovering" over the list.

### Bubbly Progress Indicators
- **Linear Progress:** Use a Sparkling Mint fill.
- **Visual Flourish:** Add 3-4 small circular "bubbles" (white, 40% opacity) that animate slowly from left to right within the progress bar to simulate carbonation.

### Input Fields
- **Style:** Outlined Material Design 3 style with a 12px radius.
- **Focus:** The border should transition to 2px Indigo Refresh on focus.

### Lists
- Use generous vertical padding (16px) between items.
- Incorporate "Dividers" only where necessary, preferably using whitespace and tonal shifts to separate groups.