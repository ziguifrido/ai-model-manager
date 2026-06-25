# AI Model Manager — Branding

## Design Rationale

The icon communicates the application's core purpose: **managing a local library of AI models**, not running AI inference or chatting with a bot.

### Concept: Layered Model Catalog

The icon depicts three layered "model cards" — a visual metaphor for an organized catalog or library of AI models. The layering suggests a collection, archive, or repository.

| Element | Meaning |
|---------|---------|
| **Stacked cards** | A library, catalog, or collection of models |
| **Interconnected nodes** | The AI / machine learning domain — models as structured data |
| **Hexagonal motifs** | Technical precision, neural network topology, organization |
| **Bottom accent bar** | A "shelf" or foundation — the local filesystem that hosts the models |
| **White card surface** | Clarity, readability, cleanliness — the app's UI philosophy |

### What It Does Not Suggest

- No chatbot or speech bubble — this is not a chat app
- No sparkle or magic wand — this is a management tool, not a generator
- No robot or brain — the interface is about files, not consciousness
- No cloud — everything is local

### Color Palette

| Color | Usage | Hex |
|-------|-------|-----|
| Deep Indigo | Background gradient top | `#143370` |
| Slate Blue | Background gradient bottom | #26528C |
| White (92–95% opacity) | Model card surfaces | #FFFFFF |
| Light Blue (85% opacity) | AI node fills | #80BFFF |
| Muted Blue (30% opacity) | Connection lines | #99CCFF |
| Steel Blue (25% opacity) | Base accent bar | #66A6F2 |

The palette uses **cool technical blues** that align with:

- Professional developer tools
- macOS design language
- Trust, precision, organization
- Light and Dark Mode compatibility

### macOS Style Compliance

- Rounded square shape (22% corner radius — matches Apple's app icon proportions)
- Subtle depth through layered cards and shadows
- Restrained gradient from indigo to slate blue
- Soft glass highlight in the top-left
- No skeuomorphism
- Recognizable at 16×16px (high-contrast shapes, clean lines)

---

## Source Assets

Located in `Resources/Brand/`:

| File | Description |
|------|-------------|
| `AIModelManagerIcon.png` | 1024×1024 PNG — master artwork |
| `AIModelManagerIcon.swift` | Swift + CoreGraphics script to regenerate the icon |

To regenerate all icon sizes:

```bash
swift Resources/Brand/AIModelManagerIcon.swift
```

The script renders the SVG via NSImage and writes all sizes directly to `AIModelManager/Assets.xcassets/AppIcon.appiconset/icon_*.png`, as well as a 1024×1024 master to `Resources/Brand/AIModelManagerIcon.png`.

---

## Usage

### App Icon

The icon is used as the macOS application icon via the Xcode asset catalog at `AIModelManager/Assets.xcassets/AppIcon.appiconset/`.

### Extended Branding

The same design language can be reused for:

- **README social preview** — gradient background + symbol
- **Website hero** — card layout with hexagonal motif
- **GitHub repository** — as the social preview image
- **Documentation** — as a favicon or page icon
- **Installer** — as DMG background or installer icon

---

## Design Rules for Extensions

When extending the brand:

- Use the same blue/indigo/slate palette
- Keep the rounded-square shape
- Maintain the same level of detail (no extra gradients, no photorealistic elements)
- Prefer geometric precision over ornamentation
- Use SF Symbols or simple geometric shapes for supplementary icons
