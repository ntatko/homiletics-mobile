#!/usr/bin/env python3
"""Draws the Android launch screen's "13one.org" branding line.

Android 12+ shows it under the animated mark (windowSplashScreenBrandingImage,
a 200x80dp image); older versions put the same image at the bottom of
launch_background.xml. Muted ink on transparent, one set per theme.

    python3 tool/splash/build_splash_branding.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "android/app/src/main/res"
FONT = ROOT / "assets/fonts/PublicSans-Medium.ttf"
TEXT = "13one.org"

# The app's muted ink (AppColors.muted), a little softer: it's a footnote.
COLORS = {"": (0x5A, 0x62, 0x6C, 200), "night-": (0xA4, 0xAA, 0xB3, 190)}
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
WIDTH_DP, HEIGHT_DP = 200, 80
TEXT_DP = 13  # cap-height-ish size of the line
TRACKING = 0.06  # extra space between letters, in ems


def draw(scale: float, color) -> Image.Image:
    w, h = round(WIDTH_DP * scale), round(HEIGHT_DP * scale)
    image = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    font = ImageFont.truetype(str(FONT), round(TEXT_DP * scale))
    d = ImageDraw.Draw(image)
    gap = TEXT_DP * scale * TRACKING
    widths = [d.textlength(ch, font=font) for ch in TEXT]
    total = sum(widths) + gap * (len(TEXT) - 1)
    x = (w - total) / 2
    _, top, _, bottom = font.getbbox(TEXT)
    y = (h - (bottom - top)) / 2 - top
    for ch, cw in zip(TEXT, widths):
        d.text((x, y), ch, font=font, fill=color)
        x += cw + gap
    return image


def main() -> None:
    for night, color in COLORS.items():
        for density, scale in DENSITIES.items():
            folder = RES / f"drawable-{night}{density}"
            folder.mkdir(parents=True, exist_ok=True)
            draw(scale, color).save(folder / "splash_branding.png", optimize=True)
            print(folder / "splash_branding.png")


if __name__ == "__main__":
    main()
