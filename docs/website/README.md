# Mindful Moments — Website

Static HTML/CSS website for the Mindful Moments iOS app.

## Files

| File | Description |
|------|-------------|
| `index.html` | Main landing page (hero, themes, features, privacy summary, FAQ) |
| `privacy.html` | Full privacy policy |
| `style.css` | All styles — shared by both pages |

---

## ✅ How to publish with GitHub Pages (free)

### Step 1 — Push the repo to GitHub
Make sure your project is pushed to a GitHub repository. If it already is, skip to Step 2.

### Step 2 — Enable GitHub Pages
1. Open your repository on github.com.
2. Click **Settings** → **Pages** (left sidebar).
3. Under **Source**, choose **Deploy from a branch**.
4. Set **Branch** to `main` (or whichever branch you use) and set the folder to `/docs/website`.
   > ⚠️ If GitHub Pages only lets you pick `/` or `/docs` as the folder root, move the three website files directly into `docs/` and update the folder setting to `/docs`.
5. Click **Save**.
6. After a minute or two, GitHub will show you a live URL like `https://yourusername.github.io/mindful-moments`.

### Step 3 — Custom domain (optional)
If you own a domain (e.g. `mindfulmoments.app`):
1. Add a file called `CNAME` in the same folder as `index.html`, containing just your domain:
   ```
   mindfulmoments.app
   ```
2. Point your domain's DNS to GitHub Pages by adding a CNAME record to `yourusername.github.io`.
3. Back in GitHub → Settings → Pages, enter your custom domain and tick **Enforce HTTPS**.

---

## 💡 Before you go live — checklist

- [ ] Replace `hello@mindfulmoments.app` in `index.html` and `privacy.html` with your real support email.
- [ ] Replace the `href="#"` on the "Download on the App Store" button with your actual App Store URL once the app is live.
- [ ] Replace the three phone-mockup placeholder cards with real screenshots when you have them (crop them to ~170 × 320 px and save as `screen1.png`, `screen2.png`, `screen3.png`).
- [ ] Update the `og:image` meta tag in `index.html` to a real preview image for social sharing.
- [ ] Check the iOS version requirement in the FAQ matches your actual deployment target.

---

## 🌐 Preview locally

Open `index.html` in any web browser — no build step or server needed.
