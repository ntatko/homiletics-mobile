#!/usr/bin/env python3
"""Builds App Store / Play Store screenshot artwork for Homiletics.

    python3 tool/store_art/build_store_art.py --shots <dir> --out <dir> [--lang en]
                                               [--sets iphone,ipad,mac,play,feature]

<shots> holds the raw app captures:
    iphone/{light,dark}_<screen>[_<lang>].png   1320x2868 (iPhone 6.9")
    ipad/…                                       1640x2360 (iPad Air 11")
    macos/…                                      3456x2048 window captures
    android/…                                    1080x2424 (Pixel 9a)
(capture them with tool/store_art/capture_sim.sh and capture_android.sh).

Captions come from captions.json next to this script, keyed by language, so
the artwork can be translated without touching the layout. Every output is
an RGB PNG at the exact store size; a contact sheet per set is written too.
"""
import argparse
import json
import math
import os
import random
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
FONTS = os.path.join(REPO, 'assets', 'fonts')

AMBER = (252, 175, 23)
SLATE = (51, 63, 72)
TEAL = (73, 197, 177)
WHITE = (255, 255, 255)
SLATE_SUB = (198, 207, 214)
SS = 3  # supersampling for anti-aliased shapes


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), int(round(size)))


# --------------------------------------------------------------- shapes ---

def rr_mask(size, radius, ss=SS):
    """Anti-aliased rounded-rectangle mask."""
    w, h = size
    m = Image.new('L', (w * ss, h * ss), 0)
    ImageDraw.Draw(m).rounded_rectangle(
        (0, 0, w * ss - 1, h * ss - 1), radius=radius * ss, fill=255)
    return m.resize((w, h), Image.LANCZOS)


def rr_layer(size, radius, color):
    layer = Image.new('RGBA', size, color + (255,))
    layer.putalpha(rr_mask(size, radius))
    return layer


def ellipse_layer(d, color):
    m = Image.new('L', (d * SS, d * SS), 0)
    ImageDraw.Draw(m).ellipse((0, 0, d * SS - 1, d * SS - 1), fill=255)
    layer = Image.new('RGBA', (d, d), color + (255,))
    layer.putalpha(m.resize((d, d), Image.LANCZOS))
    return layer


def rounded_shot(shot, radius):
    shot = shot.convert('RGBA')
    mask = rr_mask(shot.size, radius)
    if shot.getextrema()[3][0] < 255:  # keep the capture's own transparency
        from PIL import ImageChops
        mask = ImageChops.multiply(mask, shot.getchannel('A'))
    shot.putalpha(mask)
    return shot


# ------------------------------------------------------------- devices ---

DEVICES = {
    # bezel and screen corner radius as a fraction of the screen width
    'iphone': dict(bezel=0.034, radius=0.135, rim=0.0065,
                   rim_color=(74, 78, 84), body=(12, 13, 15), buttons=True),
    'android': dict(bezel=0.040, radius=0.095, rim=0.0065,
                    rim_color=(70, 74, 80), body=(12, 13, 15), buttons=True,
                    punch_hole=True),
    'ipad': dict(bezel=0.040, radius=0.030, rim=0.0045,
                 rim_color=(82, 86, 92), body=(14, 15, 17), buttons=False),
}


def device_image(shot, screen_w, kind):
    """Returns an RGBA image of the capture inside a drawn device frame."""
    if kind == 'mac':
        return mac_window(shot, screen_w)
    spec = DEVICES[kind]
    sw = int(screen_w)
    sh = int(round(shot.height * sw / shot.width))
    screen = shot.convert('RGBA').resize((sw, sh), Image.LANCZOS)
    b = int(round(sw * spec['bezel']))
    r = int(round(sw * spec['radius']))
    rim = max(2, int(round(sw * spec['rim'])))
    ow, oh = sw + 2 * b, sh + 2 * b
    btn = max(3, int(round(sw * 0.007))) if spec['buttons'] else 0
    img = Image.new('RGBA', (ow + 2 * btn, oh), (0, 0, 0, 0))

    if btn:
        metal = spec['rim_color']
        bw = btn * 3
        def button(x, y, h):
            img.alpha_composite(rr_layer((bw, int(h)), btn, metal), (int(x), int(y)))
        if kind == 'iphone':
            button(0, oh * 0.165, oh * 0.040)      # action button
            button(0, oh * 0.235, oh * 0.070)      # volume up
            button(0, oh * 0.320, oh * 0.070)      # volume down
            button(ow + 2 * btn - bw, oh * 0.255, oh * 0.105)  # side button
        else:
            button(ow + 2 * btn - bw, oh * 0.200, oh * 0.065)  # power
            button(ow + 2 * btn - bw, oh * 0.300, oh * 0.110)  # volume

    outer_r = r + b
    img.alpha_composite(rr_layer((ow, oh), outer_r, spec['rim_color']), (btn, 0))
    # a faint highlight on the rim so it reads as metal, not a flat line
    hl = rr_layer((ow - 2, oh - 2), outer_r - 1, tuple(min(255, c + 40) for c in spec['rim_color']))
    hl.putalpha(hl.getchannel('A').point(lambda a: a * 0.35))
    img.alpha_composite(hl, (btn + 1, 1))
    img.alpha_composite(rr_layer((ow - 2 * rim, oh - 2 * rim), outer_r - rim, spec['body']),
                        (btn + rim, rim))
    img.alpha_composite(rounded_shot(screen, r), (btn + b, b))
    if spec.get('punch_hole'):
        d = int(round(sw * 0.034))
        cam = ellipse_layer(d, (8, 8, 10))
        img.alpha_composite(cam, (btn + b + sw // 2 - d // 2, b + int(sw * 0.032)))
    return img


def mac_window(shot, width):
    """A capture of the macOS window (with its title bar) at `width` px."""
    shot = shot.convert('RGBA')
    tb = 64  # title bar height in the 2x capture
    px = shot.getpixel((shot.width // 2, tb + 20))
    light = sum(px[:3]) / 3 > 128
    bar_color = (234, 232, 228) if light else (44, 43, 42)
    bar = Image.new('RGBA', (shot.width, tb), bar_color + (255,))
    bar.putalpha(shot.crop((0, 0, shot.width, tb)).getchannel('A'))
    shot.paste(bar, (0, 0))
    line = (214, 211, 206) if light else (24, 24, 24)
    ImageDraw.Draw(shot).line((0, tb - 1, shot.width, tb - 1), fill=line + (255,), width=2)
    for i, c in enumerate([(255, 95, 87), (254, 188, 46), (40, 200, 64)]):
        d = 26
        shot.alpha_composite(ellipse_layer(d, c), (18 + i * 46, tb // 2 - d // 2))
    f = font('PublicSans-SemiBold.ttf', 26)
    title = 'Homiletics'
    d = ImageDraw.Draw(shot)
    tw = d.textlength(title, font=f)
    d.text(((shot.width - tw) / 2, tb / 2), title, font=f, anchor='lm',
           fill=(110, 108, 104) if light else (175, 172, 168))
    # a hairline border like a real window
    border = rr_layer(shot.size, 22, (0, 0, 0))
    inner = rr_mask((shot.width - 4, shot.height - 4), 20)
    a = border.getchannel('A')
    a.paste(0, (2, 2), inner)
    border.putalpha(a.point(lambda v: v * (0.18 if light else 0.6)))
    shot.alpha_composite(border)
    h = int(round(shot.height * width / shot.width))
    return shot.resize((int(width), h), Image.LANCZOS)


def drop_shadow(canvas, img, pos, strength=0.38):
    w, h = img.size
    blur = max(8, int(w * 0.035))
    pad = blur * 3
    sh = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    a = img.getchannel('A').point(lambda v: v * strength)
    black = Image.new('RGBA', (w, h), (0, 0, 0, 255))
    black.putalpha(a)
    sh.alpha_composite(black, (pad, pad))
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(sh, (int(pos[0] - pad), int(pos[1] - pad + w * 0.025)), )


def paste(canvas, img, pos):
    """alpha_composite that tolerates negative / overflowing positions."""
    x, y = int(round(pos[0])), int(round(pos[1]))
    sx, sy = max(0, -x), max(0, -y)
    if sx >= img.width or sy >= img.height:
        return
    crop = img.crop((sx, sy, min(img.width, canvas.width - x), min(img.height, canvas.height - y)))
    if crop.width <= 0 or crop.height <= 0:
        return
    canvas.alpha_composite(crop, (x + sx, y + sy))


def place_device(canvas, shot, kind, cx, top, outer_w, angle=0.0):
    spec = DEVICES.get(kind)
    screen_w = outer_w / (1 + 2 * spec['bezel']) if spec else outer_w
    dev = device_image(shot, screen_w, kind)
    if angle:
        dev = dev.rotate(angle, resample=Image.BICUBIC, expand=True)
    x = cx - dev.width / 2
    padded = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    # shadow, then device
    sh_canvas = Image.new('RGBA', (canvas.width + 4000, canvas.height + 4000), (0, 0, 0, 0))
    drop_shadow(sh_canvas, dev, (x + 2000, top + 2000))
    canvas.alpha_composite(sh_canvas.crop((2000, 2000, 2000 + canvas.width, 2000 + canvas.height)))
    paste(canvas, dev, (x, top))
    return (x, top, x + dev.width, top + dev.height)


# ---------------------------------------------------------------- text ---

def wrap(draw, text, f, max_w):
    if '\n' in text:  # explicit breaks from the captions file
        return [l for part in text.split('\n') for l in wrap(draw, part, f, max_w)]
    words = text.split(' ')
    lines, cur = [], ''
    for word in words:
        trial = (cur + ' ' + word).strip()
        if draw.textlength(trial, font=f) <= max_w or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    # balance two-line wraps so the last line isn't a lone word
    if len(lines) == 2 and len(words) > 2:
        best = lines
        best_diff = abs(draw.textlength(lines[0], font=f) - draw.textlength(lines[1], font=f))
        for i in range(1, len(words)):
            a, b = ' '.join(words[:i]), ' '.join(words[i:])
            if max(draw.textlength(a, font=f), draw.textlength(b, font=f)) <= max_w:
                diff = abs(draw.textlength(a, font=f) - draw.textlength(b, font=f))
                if diff < best_diff:
                    best, best_diff = [a, b], diff
        lines = best
    return lines


def draw_caption(canvas, box, cap, bg, scale, align='center'):
    """Draws eyebrow pill + title + subline into box (x0, y0, x1). Returns bottom y."""
    x0, y, x1 = box
    d = ImageDraw.Draw(canvas)
    on_amber = bg == AMBER
    title_c = SLATE if on_amber else WHITE
    sub_c = (77, 66, 40) if on_amber else SLATE_SUB
    max_w = x1 - x0
    cx = (x0 + x1) / 2

    def xpos(w):
        return cx - w / 2 if align == 'center' else x0

    if cap.get('eyebrow'):
        f = font('PublicSans-Bold.ttf', 44 * scale)
        text = cap['eyebrow'].upper()
        tracking = 4 * scale
        tw = sum(d.textlength(ch, font=f) for ch in text) + tracking * (len(text) - 1)
        ph, pw = 84 * scale, tw + 64 * scale
        px = xpos(pw)
        pill_bg, pill_fg = (SLATE, AMBER) if on_amber else (AMBER, SLATE)
        canvas.alpha_composite(rr_layer((int(pw), int(ph)), int(ph / 2), pill_bg), (int(px), int(y)))
        tx = px + 32 * scale
        for ch in text:
            d.text((tx, y + ph / 2), ch, font=f, fill=pill_fg, anchor='lm')
            tx += d.textlength(ch, font=f) + tracking
        y += ph + 34 * scale

    f = font('PublicSans-Bold.ttf', 118 * scale)
    for line in wrap(d, cap['title'], f, max_w):
        w = d.textlength(line, font=f)
        d.text((xpos(w), y), line, font=f, fill=title_c, anchor='la')
        y += 132 * scale
    if cap.get('sub'):
        y += 14 * scale
        f = font('PublicSans-Medium.ttf', 60 * scale)
        for line in wrap(d, cap['sub'], f, max_w):
            w = d.textlength(line, font=f)
            d.text((xpos(w), y), line, font=f, fill=sub_c, anchor='la')
            y += 78 * scale
    return y


# ------------------------------------------------------------ confetti ---

def confetti(canvas, seed, avoid, n=3, size=(0.045, 0.08), region=None):
    """Scatters small rotated teal squares, keeping clear of `avoid` boxes."""
    rnd = random.Random(seed)
    W, H = canvas.size
    rx0, ry0, rx1, ry1 = region or (0, 0, W, H)
    placed = 0
    tries = 0
    boxes = list(avoid)
    while placed < n and tries < 400:
        tries += 1
        s = int(rnd.uniform(*size) * min(W, H * 0.6))
        x = rnd.uniform(rx0 - s * 0.3, rx1 - s * 0.7)
        y = rnd.uniform(ry0, ry1 - s)
        bb = (x - s * 0.4, y - s * 0.4, x + s * 1.4, y + s * 1.4)
        if any(not (bb[2] < a[0] or bb[0] > a[2] or bb[3] < a[1] or bb[1] > a[3]) for a in boxes):
            continue
        sq = Image.new('RGBA', (s * 2, s * 2), (0, 0, 0, 0))
        ImageDraw.Draw(sq).rectangle((s // 2, s // 2, s // 2 + s, s // 2 + s), fill=TEAL + (255,))
        sq = sq.resize((s * 2 * SS, s * 2 * SS), Image.NEAREST).rotate(
            rnd.uniform(12, 40) * rnd.choice([-1, 1]), resample=Image.BICUBIC)
        sq = sq.resize((s * 2, s * 2), Image.LANCZOS)
        paste(canvas, sq, (x - s / 2, y - s / 2))
        boxes.append(bb)
        placed += 1


# --------------------------------------------------------------- brand ---

def draw_logo(canvas, cx, cy, h):
    """The teal "H." mark with its amber square, centred on (cx, cy)."""
    # proportions measured from the original brand panel
    hw, stem, bar_y, bar_h, gap, sq = 238 / 282, 70 / 282, 105 / 282, 61 / 282, 46 / 282, 66 / 282
    total_w = (hw + gap + sq) * h
    x = cx - total_w / 2
    y = cy - h / 2
    d = ImageDraw.Draw(canvas)
    r = lambda *a: tuple(int(round(v)) for v in a)
    d.rectangle(r(x, y, x + stem * h, y + h), fill=TEAL)
    d.rectangle(r(x + (hw - stem) * h, y, x + hw * h, y + h), fill=TEAL)
    d.rectangle(r(x, y + bar_y * h, x + hw * h, y + (bar_y + bar_h) * h), fill=TEAL)
    sx = x + (hw + gap) * h
    d.rectangle(r(sx, y + h - sq * h, sx + sq * h, y + h), fill=AMBER)
    return total_w


def brand_panel(size, cap, scale=1.0, wordmark_gap=0.11):
    W, H = size
    img = Image.new('RGBA', size, SLATE + (255,))
    logo_h = min(W * 0.31, H * 0.26) * scale
    cy = H * 0.42
    draw_logo(img, W / 2 + logo_h * 0.02, cy, logo_h)
    d = ImageDraw.Draw(img)
    f1 = font('PublicSans-Bold.ttf', logo_h * 0.30)
    f2 = font('PublicSans-Medium.ttf', logo_h * 0.23)
    y = cy + logo_h / 2 + H * wordmark_gap * 0.5
    d.text((W / 2, y), cap['name'], font=f1, fill=AMBER, anchor='mt')
    d.text((W / 2, y + logo_h * 0.42), cap['tagline'], font=f2, fill=TEAL, anchor='mt')
    confetti(img, 'brand%dx%d' % size, [(W * 0.08, H * 0.25, W * 0.92, H * 0.75)], n=3)
    return img


# ------------------------------------------------------------- layouts ---
#
# A "group" is one or more adjacent store images rendered on one canvas, so a
# device can straddle two of them (a panorama in the store's carousel).
# Positions are in panel units: x=1.5 is the middle of the second panel;
# y is a fraction of the panel height; w is the device's outer width as a
# fraction of the panel width.

PHONE_LAYOUT = [
    dict(panels=[(AMBER, 'dive')],
         devices=[dict(shot='light_home', x=0.5, y=0.235, w=0.74)]),
    dict(panels=[(SLATE, 'step1'), (AMBER, 'step23')],
         devices=[dict(shot='light_homiletic', x=0.76, y=0.265, w=0.72, angle=0),
                  dict(shot='light_homiletic_mid', x=1.62, y=0.265, w=0.72, angle=0)]),
    dict(panels=[(SLATE, 'step46')],
         devices=[dict(shot='dark_homiletic_late', x=0.5, y=0.265, w=0.74)]),
    dict(panels=[(AMBER, 'lecture')],
         devices=[dict(shot='light_lecture', x=0.5, y=0.29, w=0.72)]),
    dict(panels=[(SLATE, 'word')],
         devices=[dict(shot='light_wordstudy', x=0.5, y=0.265, w=0.74)]),
    dict(panels=[(AMBER, 'language')],
         devices=[dict(shot='dark_home', x=0.34, y=0.30, w=0.62, angle=6),
                  dict(shot='light_home_es', x=0.64, y=0.275, w=0.66, angle=-3)]),
    dict(panels=[(SLATE, 'brand')]),
]

TABLET_LAYOUT = [
    dict(panels=[(AMBER, 'dive')],
         devices=[dict(shot='light_home', x=0.5, y=0.215, w=0.84)]),
    dict(panels=[(SLATE, 'step1')],
         devices=[dict(shot='light_homiletic', x=0.5, y=0.25, w=0.84)]),
    dict(panels=[(AMBER, 'step46')],
         devices=[dict(shot='light_homiletic_late', x=0.5, y=0.25, w=0.84)]),
    dict(panels=[(SLATE, 'lecture')],
         devices=[dict(shot='light_lecture', x=0.5, y=0.25, w=0.84)]),
    dict(panels=[(AMBER, 'word')],
         devices=[dict(shot='light_wordstudy', x=0.5, y=0.25, w=0.84)]),
    dict(panels=[(SLATE, 'brand')]),
]

MAC_LAYOUT = [
    dict(panels=[(AMBER, 'dive')],
         devices=[dict(shot='light_home', x=0.5, y=0.2, w=0.86)]),
    dict(panels=[(SLATE, 'steps_all')],
         devices=[dict(shot='light_homiletic', x=0.5, y=0.2, w=0.86)]),
    dict(panels=[(AMBER, 'lecture_short')],
         devices=[dict(shot='dark_lecture', x=0.5, y=0.2, w=0.86)]),
    dict(panels=[(SLATE, 'word')],
         devices=[dict(shot='dark_wordstudy', x=0.5, y=0.2, w=0.86)]),
    dict(panels=[(SLATE, 'brand')]),
]

SETS = {
    'iphone': dict(size=(1320, 2868), kind='iphone', dir='iphone', layout=PHONE_LAYOUT,
                   scale=1.0, text_top=0.075, text_w=0.86),
    'play': dict(size=(1080, 2400), kind='android', dir='android', layout=PHONE_LAYOUT,
                 scale=0.82, text_top=0.07, text_w=0.88),
    'ipad': dict(size=(2064, 2752), kind='ipad', dir='ipad', layout=TABLET_LAYOUT,
                 scale=1.0, text_top=0.06, text_w=0.86, bleed=True),
    'mac': dict(size=(2880, 1800), kind='mac', dir='macos', layout=MAC_LAYOUT,
                scale=0.55, text_top=0.06, text_w=0.86, gap=0.045, bleed=True),
}


def clean_android_status_bar(img):
    """Hides notification and VPN icons that demo mode leaves on a Pixel 9a
    status bar (1080 px wide), keeping the clock, wifi and battery."""
    img = img.convert('RGBA')
    if img.width != 1080:
        return img
    bg = img.getpixel((600, 40))
    d = ImageDraw.Draw(img)
    d.rectangle((200, 35, 450, 125), fill=bg)   # notification icons
    d.rectangle((805, 35, 866, 125), fill=bg)   # VPN key
    return img


def load_shot(shots, set_dir, name):
    for cand in (name, name.replace('_es', '')):
        p = os.path.join(shots, set_dir, cand + '.png')
        if os.path.exists(p):
            if cand != name:
                print('  (missing %s, using %s)' % (name, cand))
            img = Image.open(p)
            return clean_android_status_bar(img) if set_dir == 'android' else img
    raise FileNotFoundError(os.path.join(shots, set_dir, name + '.png'))


def render_group(group, cfg, caps, shots, seed):
    W, H = cfg['size']
    n = len(group['panels'])
    canvas = Image.new('RGBA', (W * n, H), (0, 0, 0, 255))
    d = ImageDraw.Draw(canvas)
    text_boxes = []
    for i, (bg, key) in enumerate(group['panels']):
        d.rectangle((i * W, 0, (i + 1) * W, H), fill=bg)
    if group['panels'][0][1] == 'brand':
        return [brand_panel((W, H), caps['brand'])]

    # captions first, to know what the confetti must avoid
    caption_layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    for i, (bg, key) in enumerate(group['panels']):
        margin = W * (1 - cfg['text_w']) / 2
        y0 = H * cfg['text_top']
        y1 = draw_caption(caption_layer, (i * W + margin, y0, (i + 1) * W - margin),
                          caps[key], bg, cfg['scale'] * W / 1320)
        text_boxes.append((i * W + margin * 0.6, y0 - 20, (i + 1) * W - margin * 0.6, y1 + 10))

    # fit each device below the caption(s) it sits under, shrinking it if
    # it would otherwise run off the bottom (unless the layout asks to bleed)
    placed = []
    gap, bottom = H * cfg.get('gap', 0.03), H * 0.035
    for spec in group.get('devices', []):
        shot = load_shot(shots, cfg['dir'], spec['shot'])
        cx, w = spec['x'] * W, spec['w'] * W
        bez = 2 * DEVICES[cfg['kind']]['bezel'] if cfg['kind'] in DEVICES else 0
        aspect = (shot.height / shot.width + bez) / (1 + bez)
        under = [text_boxes[i][3] for i in range(n)
                 if cx - w / 2 < (i + 1) * W and cx + w / 2 > i * W]
        top = max([spec['y'] * H] + [b + gap for b in under])
        if not spec.get('bleed', cfg.get('bleed', False)) and top + w * aspect > H - bottom:
            w = (H - bottom - top) / aspect
        placed.append((shot, cx, top, w, spec.get('angle', 0)))
    if n > 1 and placed:
        # devices sharing a panorama get the same size and baseline
        top = max(p[2] for p in placed)
        w = min(p[3] for p in placed)
        placed = [(sh, cx, top, w, a) for sh, cx, _, _, a in placed]
    dev_boxes = [(cx - w / 2, top, cx + w / 2, H) for _, cx, top, w, _ in placed]
    for i in range(n):
        # confetti around the devices' edges, per panel
        confetti(canvas, '%s-%d-%d' % (seed, i, W), text_boxes + [
            (b[0] + W * 0.05, b[1] + W * 0.05, b[2] - W * 0.05, b[3]) for b in dev_boxes],
            n=3, region=(i * W, H * 0.15, (i + 1) * W, H * 0.97))
    for shot, cx, top, w, angle in placed:
        place_device(canvas, shot, cfg['kind'], cx, top, w, angle)
    canvas.alpha_composite(caption_layer)
    return [canvas.crop((i * W, 0, (i + 1) * W, H)) for i in range(n)]


def contact_sheet(paths, out, height=900):
    ims = [Image.open(p).convert('RGB') for p in paths]
    row = [im.resize((int(im.width * height / im.height), height), Image.LANCZOS) for im in ims]
    gap = 16
    W = sum(r.width for r in row) + gap * (len(row) + 1)
    sheet = Image.new('RGB', (W, height + 2 * gap), (230, 230, 230))
    x = gap
    for r in row:
        sheet.paste(r, (x, gap))
        x += r.width + gap
    sheet.save(out)


# ---------------------------------------------------- feature graphic ---

def feature_graphic(shots, caps, out):
    W, H = 1024, 500
    img = Image.new('RGBA', (W, H), SLATE + (255,))
    d = ImageDraw.Draw(img)
    # amber band on the right, cut at an angle
    d.polygon([(W * 0.56, 0), (W, 0), (W, H), (W * 0.48, H)], fill=AMBER)
    confetti(img, 'feature', [(40, 60, 470, 440), (560, 40, 1000, 500)], n=4,
             size=(0.05, 0.08))
    logo_h = 150
    draw_logo(img, 245, 175, logo_h)
    d = ImageDraw.Draw(img)
    d.text((245, 290), caps['brand']['name'], font=font('PublicSans-Bold.ttf', 62),
           fill=AMBER, anchor='mt')
    d.text((245, 366), caps['brand']['tagline'], font=font('PublicSans-Medium.ttf', 44),
           fill=TEAL, anchor='mt')
    a = load_shot(shots, 'android', 'light_homiletic') if os.path.isdir(
        os.path.join(shots, 'android')) else load_shot(shots, 'iphone', 'light_homiletic')
    b = load_shot(shots, 'android', 'light_home') if os.path.isdir(
        os.path.join(shots, 'android')) else load_shot(shots, 'iphone', 'light_home')
    place_device(img, b, 'android', 680, 70, 250, angle=4)
    place_device(img, a, 'android', 860, 40, 260, angle=-4)
    img.convert('RGB').save(out)


# ----------------------------------------------------------------- main ---

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--shots', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--lang', default='en')
    ap.add_argument('--sets', default='iphone,ipad,mac,play,feature')
    args = ap.parse_args()

    with open(os.path.join(HERE, 'captions.json'), encoding='utf-8') as fh:
        all_caps = json.load(fh)
    caps = dict(all_caps['en'])
    caps.update(all_caps.get(args.lang, {}))

    for name in args.sets.split(','):
        out_dir = os.path.join(args.out, args.lang, name)
        os.makedirs(out_dir, exist_ok=True)
        if name == 'feature':
            p = os.path.join(out_dir, 'feature_graphic_1024x500.png')
            feature_graphic(args.shots, caps, p)
            print('wrote', p)
            continue
        cfg = SETS[name]
        if not os.path.isdir(os.path.join(args.shots, cfg['dir'])):
            print('skipping %s: no %s captures' % (name, cfg['dir']))
            continue
        paths = []
        idx = 1
        for gi, group in enumerate(cfg['layout']):
            rendered = render_group(group, cfg, caps, args.shots, '%s-%d' % (name, gi))
            for (_, key), panel in zip(group['panels'], rendered):
                W, H = cfg['size']
                p = os.path.join(out_dir, '%02d_%s_%dx%d.png' % (idx, key, W, H))
                panel.convert('RGB').save(p, optimize=True)
                paths.append(p)
                idx += 1
        contact_sheet(paths, os.path.join(args.out, args.lang, '%s_sheet.png' % name))
        print('wrote %d images to %s' % (len(paths), out_dir))


if __name__ == '__main__':
    main()
